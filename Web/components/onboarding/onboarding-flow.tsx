"use client"

import type React from "react"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { createBrowserClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Flower2, Camera, Sparkles, ArrowRight, Upload } from "lucide-react"

interface OnboardingFlowProps {
  userId: string
}

const INTERESTS = [
  { id: "gardening", label: "Gardening", icon: "🌱" },
  { id: "photography", label: "Photography", icon: "📸" },
  { id: "botany", label: "Botany", icon: "🔬" },
  { id: "landscaping", label: "Landscaping", icon: "🏡" },
  { id: "conservation", label: "Conservation", icon: "🌍" },
  { id: "education", label: "Education", icon: "📚" },
]

const FLOWER_TYPES = [
  "Roses",
  "Tulips",
  "Orchids",
  "Sunflowers",
  "Lilies",
  "Daisies",
  "Carnations",
  "Chrysanthemums",
  "Peonies",
  "Hydrangeas",
  "Lavender",
  "Jasmine",
]

export default function OnboardingFlow({ userId }: OnboardingFlowProps) {
  const router = useRouter()
  const supabase = createBrowserClient()
  const [step, setStep] = useState(1)
  const [loading, setLoading] = useState(false)

  // Step 1: Basic Info
  const [displayName, setDisplayName] = useState("")
  const [bio, setBio] = useState("")
  const [avatar, setAvatar] = useState<File | null>(null)
  const [avatarPreview, setAvatarPreview] = useState<string | null>(null)

  // Step 2: Interests
  const [selectedInterests, setSelectedInterests] = useState<string[]>([])

  // Step 3: Favorite Flowers
  const [selectedFlowers, setSelectedFlowers] = useState<string[]>([])

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setAvatar(file)
      const reader = new FileReader()
      reader.onloadend = () => {
        setAvatarPreview(reader.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const toggleInterest = (interest: string) => {
    setSelectedInterests((prev) => (prev.includes(interest) ? prev.filter((i) => i !== interest) : [...prev, interest]))
  }

  const toggleFlower = (flower: string) => {
    setSelectedFlowers((prev) => (prev.includes(flower) ? prev.filter((f) => f !== flower) : [...prev, flower]))
  }

  const handleComplete = async () => {
    setLoading(true)
    try {
      // Upload avatar if provided
      let avatarUrl = null
      if (avatar) {
        const fileExt = avatar.name.split(".").pop()
        const fileName = `${userId}-${Date.now()}.${fileExt}`
        const { data: uploadData, error: uploadError } = await supabase.storage.from("avatars").upload(fileName, avatar)

        if (!uploadError && uploadData) {
          const { data: urlData } = supabase.storage.from("avatars").getPublicUrl(uploadData.path)
          avatarUrl = urlData.publicUrl
        }
      }

      // Update profile
      const { error } = await supabase
        .from("profiles")
        .update({
          display_name: displayName || null,
          full_name: displayName || null, // Sync full_name with display_name
          bio: bio || null,
          avatar_url: avatarUrl,
          interests: selectedInterests,
          favorite_flowers: selectedFlowers,
          onboarding_completed: true,
        })
        .eq("id", userId)

      if (error) throw error

      router.push("/feed")
      router.refresh()
    } catch (error) {
      console.error("Error completing onboarding:", error)
      alert("Failed to complete onboarding. Please try again.")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="container max-w-2xl mx-auto px-4 py-12">
      {/* Progress indicator */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-2">
          <span className="text-sm font-medium text-emerald-700">Step {step} of 3</span>
          <span className="text-sm text-neutral-600">{Math.round((step / 3) * 100)}%</span>
        </div>
        <div className="h-2 bg-emerald-100 rounded-full overflow-hidden">
          <div
            className="h-full bg-emerald-600 transition-all duration-300"
            style={{ width: `${(step / 3) * 100}%` }}
          />
        </div>
      </div>

      {/* Step 1: Basic Info */}
      {step === 1 && (
        <Card className="border-emerald-200 shadow-lg">
          <CardHeader className="text-center">
            <div className="mx-auto w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mb-4">
              <Flower2 className="w-8 h-8 text-emerald-600" />
            </div>
            <CardTitle className="text-2xl">Welcome to FlowerShare!</CardTitle>
            <CardDescription className="text-base">
              Let's set up your profile so you can start sharing your love for flowers
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Avatar Upload */}
            <div className="flex flex-col items-center gap-4">
              <div className="relative">
                {avatarPreview ? (
                  <img
                    src={avatarPreview || "/placeholder.svg"}
                    alt="Avatar preview"
                    className="w-24 h-24 rounded-full object-cover border-4 border-emerald-200"
                  />
                ) : (
                  <div className="w-24 h-24 rounded-full bg-emerald-100 flex items-center justify-center border-4 border-emerald-200">
                    <Camera className="w-8 h-8 text-emerald-600" />
                  </div>
                )}
                <label className="absolute bottom-0 right-0 bg-emerald-600 text-white p-2 rounded-full cursor-pointer hover:bg-emerald-700 transition-colors">
                  <Upload className="w-4 h-4" />
                  <input type="file" accept="image/*" onChange={handleAvatarChange} className="hidden" />
                </label>
              </div>
              <p className="text-sm text-neutral-600">Upload your profile picture</p>
            </div>

            {/* Display Name */}
            <div className="space-y-2">
              <Label htmlFor="displayName">Display Name</Label>
              <Input
                id="displayName"
                placeholder="How should we call you?"
                value={displayName}
                onChange={(e) => setDisplayName(e.target.value)}
                className="border-emerald-200 focus-visible:ring-emerald-500"
              />
            </div>

            {/* Bio */}
            <div className="space-y-2">
              <Label htmlFor="bio">Bio</Label>
              <Textarea
                id="bio"
                placeholder="Tell us about yourself and your passion for flowers..."
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                rows={4}
                className="border-emerald-200 focus-visible:ring-emerald-500 resize-none"
              />
              <p className="text-xs text-neutral-500">{bio.length}/500 characters</p>
            </div>

            <Button onClick={() => setStep(2)} className="w-full bg-emerald-600 hover:bg-emerald-700" size="lg">
              Continue
              <ArrowRight className="w-4 h-4 ml-2" />
            </Button>
          </CardContent>
        </Card>
      )}

      {/* Step 2: Interests */}
      {step === 2 && (
        <Card className="border-emerald-200 shadow-lg">
          <CardHeader className="text-center">
            <div className="mx-auto w-16 h-16 bg-teal-100 rounded-full flex items-center justify-center mb-4">
              <Sparkles className="w-8 h-8 text-teal-600" />
            </div>
            <CardTitle className="text-2xl">What are your interests?</CardTitle>
            <CardDescription className="text-base">
              Select all that apply so we can personalize your experience
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid grid-cols-2 gap-3">
              {INTERESTS.map((interest) => (
                <button
                  key={interest.id}
                  onClick={() => toggleInterest(interest.id)}
                  className={`p-4 rounded-lg border-2 transition-all text-left ${selectedInterests.includes(interest.id)
                      ? "border-emerald-500 bg-emerald-50"
                      : "border-neutral-200 hover:border-emerald-300"
                    }`}
                >
                  <div className="text-2xl mb-1">{interest.icon}</div>
                  <div className="font-medium text-sm">{interest.label}</div>
                </button>
              ))}
            </div>

            <div className="flex gap-3">
              <Button onClick={() => setStep(1)} variant="outline" className="flex-1" size="lg">
                Back
              </Button>
              <Button
                onClick={() => setStep(3)}
                className="flex-1 bg-emerald-600 hover:bg-emerald-700"
                size="lg"
                disabled={selectedInterests.length === 0}
              >
                Continue
                <ArrowRight className="w-4 h-4 ml-2" />
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Step 3: Favorite Flowers */}
      {step === 3 && (
        <Card className="border-emerald-200 shadow-lg">
          <CardHeader className="text-center">
            <div className="mx-auto w-16 h-16 bg-pink-100 rounded-full flex items-center justify-center mb-4">
              <Flower2 className="w-8 h-8 text-pink-600" />
            </div>
            <CardTitle className="text-2xl">What are your favorite flowers?</CardTitle>
            <CardDescription className="text-base">
              Choose your favorites to get personalized recommendations
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid grid-cols-3 gap-3">
              {FLOWER_TYPES.map((flower) => (
                <button
                  key={flower}
                  onClick={() => toggleFlower(flower)}
                  className={`p-3 rounded-lg border-2 transition-all text-center text-sm ${selectedFlowers.includes(flower)
                      ? "border-pink-500 bg-pink-50 font-medium"
                      : "border-neutral-200 hover:border-pink-300"
                    }`}
                >
                  {flower}
                </button>
              ))}
            </div>

            <div className="flex gap-3">
              <Button onClick={() => setStep(2)} variant="outline" className="flex-1" size="lg">
                Back
              </Button>
              <Button
                onClick={handleComplete}
                className="flex-1 bg-emerald-600 hover:bg-emerald-700"
                size="lg"
                disabled={loading || selectedFlowers.length === 0}
              >
                {loading ? "Completing..." : "Complete Setup"}
              </Button>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
