"use client"

import type React from "react"

import { useState, useEffect, useRef } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import { createClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Upload, X, Loader2, ImageIcon, Sparkles } from "lucide-react"
import { MapboxLocationPicker } from "@/components/map/mapbox-location-picker"

interface UploadFormProps {
  userId: string
  groupId?: string
}

export function UploadForm({ userId, groupId }: UploadFormProps) {
  const [images, setImages] = useState<File[]>([])
  const [previews, setPreviews] = useState<string[]>([])
  const [caption, setCaption] = useState("")
  const [flowerName, setFlowerName] = useState("")
  const [flowerSpecies, setFlowerSpecies] = useState("")
  const [aiConfidence, setAiConfidence] = useState<number | null>(null)
  const [location, setLocation] = useState("")
  const [coordinates, setCoordinates] = useState<{ lat: number; lng: number } | null>(null)
  const [isUploading, setIsUploading] = useState(false)
  const [isIdentifying, setIsIdentifying] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()
  const searchParams = useSearchParams()
  const supabase = createClient()
  const captionTextareaRef = useRef<HTMLTextAreaElement>(null)
  const flowerSpeciesTextareaRef = useRef<HTMLTextAreaElement>(null)

  useEffect(() => {
    const name = searchParams.get("flowerName")
    const species = searchParams.get("flowerSpecies")
    const description = searchParams.get("description")
    const care = searchParams.get("care")
    const captionParam = searchParams.get("caption") // Fallback cho caption cũ
    const imageUrl = searchParams.get("imageUrl")

    // Debug: Kiểm tra params nhận được
    console.log("Upload form params:", {
      name,
      species,
      description,
      care,
      captionParam,
      imageUrl
    })

    if (name) setFlowerName(name)
    if (species) setFlowerSpecies(species)

    // Khi share, ưu tiên lấy description và care, nếu không có thì dùng caption
    if (description || care) {
      const parts: string[] = []
      if (description && description.trim()) parts.push(description.trim())
      if (care && care.trim()) parts.push(care.trim())
      const fullText = parts.join("\n\n")
      console.log("Setting caption from description/care:", fullText)
      setCaption(fullText)
    } else if (captionParam && captionParam.trim()) {
      // Fallback: nếu không có description/care thì dùng caption cũ
      console.log("Setting caption from caption param:", captionParam)
      setCaption(captionParam)
    }

    if (imageUrl) {
      setIsIdentifying(true) // Show loading state while fetching
      fetch(imageUrl)
        .then(async (response) => {
          const blob = await response.blob()
          const file = new File([blob], "shared_flower.jpg", { type: blob.type })

          setImages([file])
          setPreviews([URL.createObjectURL(file)])
        })
        .catch((err) => {
          console.error("Failed to load shared image:", err)
          setError("Failed to load shared image")
        })
        .finally(() => setIsIdentifying(false))
    }
  }, [searchParams])

  // Auto-resize caption textarea
  useEffect(() => {
    const textarea = captionTextareaRef.current
    if (textarea) {
      textarea.style.height = "auto"
      textarea.style.height = `${textarea.scrollHeight}px`
    }
  }, [caption])

  // Auto-resize flower species textarea
  useEffect(() => {
    const textarea = flowerSpeciesTextareaRef.current
    if (textarea) {
      textarea.style.height = "auto"
      textarea.style.height = `${textarea.scrollHeight}px`
    }
  }, [flowerSpecies])

  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || [])
    if (files.length === 0) return

    // Limit to 5 images
    const newImages = [...images, ...files].slice(0, 5)
    setImages(newImages)

    // Create previews
    const newPreviews = newImages.map((file) => URL.createObjectURL(file))
    setPreviews(newPreviews)
  }

  const removeImage = (index: number) => {
    const newImages = images.filter((_, i) => i !== index)
    const newPreviews = previews.filter((_, i) => i !== index)
    setImages(newImages)
    setPreviews(newPreviews)
  }

  const handleIdentifyFlower = async () => {
    if (images.length === 0) {
      setError("Please select an image first")
      return
    }

    setIsIdentifying(true)
    setError(null)

    try {
      const formData = new FormData()
      formData.append("image", images[0])

      const response = await fetch("/api/identify-flower", {
        method: "POST",
        body: formData,
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || "Failed to identify flower")
      }

      setFlowerName(data.result.flower_name)
      setFlowerSpecies(data.result.flower_species)
      setAiConfidence(data.result.confidence)
    } catch (error) {
      console.error("[v0] Identification error:", error)
      setError(error instanceof Error ? error.message : "Failed to identify flower")
    } finally {
      setIsIdentifying(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (images.length === 0) {
      setError("Please select at least one image")
      return
    }

    setIsUploading(true)
    setError(null)

    try {
      // Create post first
      const { data: post, error: postError } = await supabase
        .from("posts")
        .insert({
          author_id: userId,
          caption: caption || null,
          flower_name: flowerName || null,
          flower_species: flowerSpecies || null,
          ai_confidence: aiConfidence,
          location_name: location || null,
          latitude: coordinates?.lat,
          longitude: coordinates?.lng,
          status: "approved",
          is_public: true,
        })
        .select()
        .single()

      if (postError) throw postError

      // Upload images to Supabase Storage
      const uploadPromises = images.map(async (image, index) => {
        const fileExt = image.name.split(".").pop()
        const fileName = `${userId}/${post.id}/${Date.now()}-${index}.${fileExt}`

        const { data: uploadData, error: uploadError } = await supabase.storage
          .from("post-images")
          .upload(fileName, image)

        if (uploadError) throw uploadError

        // Get public URL
        const {
          data: { publicUrl },
        } = supabase.storage.from("post-images").getPublicUrl(fileName)

        // Create post_media record
        const { error: mediaError } = await supabase.from("post_media").insert({
          post_id: post.id,
          media_url: publicUrl,
          media_type: "image",
          display_order: index,
        })

        if (mediaError) throw mediaError
      })

      await Promise.all(uploadPromises)

      // Set the first image as the main image_url for the post
      if (images.length > 0) {
        // Get the first image URL we just created
        const { data: firstMedia } = await supabase
          .from("post_media")
          .select("media_url")
          .eq("post_id", post.id)
          .order("display_order", { ascending: true })
          .limit(1)
          .single()

        if (firstMedia) {
          await supabase
            .from("posts")
            .update({ image_url: firstMedia.media_url })
            .eq("id", post.id)
        }
      }

      // If this is a group post, create a record in group_posts
      if (groupId) {
        const { error: groupPostError } = await supabase.from("group_posts").insert({
          group_id: groupId,
          post_id: post.id,
        })

        if (groupPostError) throw groupPostError
        router.push(`/groups/${groupId}`)
      } else {
        router.push("/feed")
      }
      router.refresh()
    } catch (error) {
      console.error("[v0] Upload error:", JSON.stringify(error, null, 2))
      setError(error instanceof Error ? error.message : "Failed to upload post")
    } finally {
      setIsUploading(false)
    }
  }

  return (
    <Card className="border-emerald-100 shadow-xl">
      <CardHeader>
        <CardTitle className="text-2xl text-emerald-900">Create Post</CardTitle>
        <CardDescription>Share your beautiful flower discovery with the community</CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Image Upload */}
          <div className="space-y-3">
            <Label>Images (up to 5)</Label>
            {previews.length > 0 ? (
              <div className="grid grid-cols-3 gap-3">
                {previews.map((preview, index) => (
                  <div
                    key={index}
                    className="relative aspect-square overflow-hidden rounded-lg border-2 border-emerald-200"
                  >
                    <img
                      src={preview || "/placeholder.svg"}
                      alt={`Preview ${index + 1}`}
                      className="h-full w-full object-cover"
                    />
                    <button
                      type="button"
                      onClick={() => removeImage(index)}
                      className="absolute right-2 top-2 rounded-full bg-red-500 p-1 text-white hover:bg-red-600"
                    >
                      <X className="h-4 w-4" />
                    </button>
                  </div>
                ))}
                {images.length < 5 && (
                  <label className="flex aspect-square cursor-pointer flex-col items-center justify-center gap-2 rounded-lg border-2 border-dashed border-emerald-300 bg-emerald-50 hover:bg-emerald-100">
                    <Upload className="h-8 w-8 text-emerald-600" />
                    <span className="text-sm text-emerald-700">Add more</span>
                    <input type="file" accept="image/*" multiple onChange={handleImageSelect} className="hidden" />
                  </label>
                )}
              </div>
            ) : (
              <label className="flex min-h-[200px] cursor-pointer flex-col items-center justify-center gap-3 rounded-lg border-2 border-dashed border-emerald-300 bg-emerald-50 hover:bg-emerald-100">
                <ImageIcon className="h-12 w-12 text-emerald-600" />
                <div className="text-center">
                  <p className="font-medium text-emerald-900">Click to upload images</p>
                  <p className="text-sm text-emerald-600">PNG, JPG up to 10MB</p>
                </div>
                <input type="file" accept="image/*" multiple onChange={handleImageSelect} className="hidden" />
              </label>
            )}
          </div>

          {/* AI Identification Button */}
          {images.length > 0 && (
            <Button
              type="button"
              onClick={handleIdentifyFlower}
              disabled={isIdentifying}
              variant="outline"
              className="w-full border-emerald-600 text-emerald-700 hover:bg-emerald-50 bg-transparent"
            >
              {isIdentifying ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Identifying flower...
                </>
              ) : (
                <>
                  <Sparkles className="mr-2 h-4 w-4" />
                  Identify Flower with AI
                </>
              )}
            </Button>
          )}

          {/* AI Results */}
          {flowerName && aiConfidence && (
            <div className="rounded-lg bg-emerald-50 p-4">
              <div className="flex items-start gap-2">
                <Sparkles className="mt-0.5 h-5 w-5 shrink-0 text-emerald-600" />
                <div className="flex-1">
                  <p className="font-semibold text-emerald-900">AI Identification Result</p>
                  <p className="mt-1 text-sm text-emerald-700">
                    Detected: <span className="font-medium">{flowerName}</span>
                    {flowerSpecies && <span className="italic"> ({flowerSpecies})</span>}
                  </p>
                  <p className="mt-1 text-xs text-emerald-600">Confidence: {aiConfidence}%</p>
                </div>
              </div>
            </div>
          )}

          {/* Flower Name */}
          <div className="space-y-2">
            <Label htmlFor="flowerName">Flower Name</Label>
            <Input
              id="flowerName"
              placeholder="e.g., Rose, Tulip, Sunflower"
              value={flowerName}
              onChange={(e) => setFlowerName(e.target.value)}
              className="border-emerald-200 focus:border-emerald-500"
            />
          </div>

          {/* Flower Species */}
          <div className="space-y-2">
            <Label htmlFor="flowerSpecies">Scientific Name (Optional)</Label>
            <Textarea
              ref={flowerSpeciesTextareaRef}
              id="flowerSpecies"
              placeholder="e.g., Rosa, Tulipa"
              value={flowerSpecies}
              onChange={(e) => setFlowerSpecies(e.target.value)}
              className="border-emerald-200 focus:border-emerald-500 min-h-[40px] resize-none overflow-hidden"
              style={{ height: "auto" }}
            />
          </div>

          {/* Caption */}
          <div className="space-y-2">
            <Label htmlFor="caption">Caption (Optional)</Label>
            <Textarea
              ref={captionTextareaRef}
              id="caption"
              placeholder="Share something about this flower..."
              value={caption}
              onChange={(e) => setCaption(e.target.value)}
              className="border-emerald-200 focus:border-emerald-500 min-h-[100px] resize-none overflow-hidden"
              style={{ height: "auto" }}
            />
          </div>

          {/* Location */}
          <div className="space-y-2">
            <MapboxLocationPicker
              value={location}
              onChange={setLocation}
              onCoordinatesChange={setCoordinates}
            />
          </div>

          {error && <div className="rounded-lg bg-red-50 p-3 text-sm text-red-600">{error}</div>}

          <div className="flex gap-3">
            <Button
              type="button"
              variant="outline"
              onClick={() => router.back()}
              disabled={isUploading}
              className="flex-1"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={isUploading || images.length === 0}
              className="flex-1 bg-emerald-600 hover:bg-emerald-700"
            >
              {isUploading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Uploading...
                </>
              ) : (
                "Share Post"
              )}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  )
}
