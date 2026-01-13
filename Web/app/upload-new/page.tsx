/**
 * Create Post Page
 * Upload image and create flower post
 */

'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Sparkles, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Slider } from '@/components/ui/slider';
import { ImageUploader } from '@/components/upload/image-uploader';
import { posts as postsApi } from '@/lib/supabase/api';
import { toast } from 'sonner';
import { MapboxLocationPicker } from '@/components/map/mapbox-location-picker';

export default function CreatePostPage() {
    const router = useRouter();

    // Image state
    const [selectedImage, setSelectedImage] = useState<File | null>(null);
    const [previewUrl, setPreviewUrl] = useState<string | null>(null);

    // Form state
    const [flowerName, setFlowerName] = useState('');
    const [flowerDescription, setFlowerDescription] = useState('');
    const [plantingGuide, setPlantingGuide] = useState('');
    const [aiConfidence, setAiConfidence] = useState(85);
    const [caption, setCaption] = useState('');
    const [locationName, setLocationName] = useState('');

    // UI state
    const [uploading, setUploading] = useState(false);
    const [step, setStep] = useState<'upload' | 'details' | 'preview'>('upload');

    const handleImageSelect = (file: File) => {
        setSelectedImage(file);
        setPreviewUrl(URL.createObjectURL(file));
        setStep('details');
    };

    const handleImageRemove = () => {
        setSelectedImage(null);
        setPreviewUrl(null);
        setStep('upload');
    };

    const handleSubmit = async () => {
        if (!selectedImage || !flowerName.trim()) {
            toast.error('Please provide an image and flower name');
            return;
        }

        setUploading(true);
        try {
            // 1. Upload image
            const imageUrl = await postsApi.uploadImage(selectedImage);

            // 2. Create post
            await postsApi.create({
                flowerName: flowerName.trim(),
                flowerDescription: flowerDescription.trim() || undefined,
                plantingGuide: plantingGuide.trim() || undefined,
                aiConfidence,
                imageUrl,
                caption: caption.trim() || undefined,
                locationName: locationName.trim() || undefined,
            });

            toast.success('Post created successfully!');
            router.push('/feed');
        } catch (error) {
            console.error('Error creating post:', error);
            toast.error('Failed to create post');
        } finally {
            setUploading(false);
        }
    };

    return (
        <div className="min-h-screen bg-gradient-to-b from-green-50 to-white">
            {/* Header */}
            <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b">
                <div className="container mx-auto max-w-2xl px-4 py-4">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <Button
                                variant="ghost"
                                size="icon"
                                onClick={() => router.back()}
                                disabled={uploading}
                            >
                                <ArrowLeft className="h-5 w-5" />
                            </Button>
                            <h1 className="text-xl font-bold">Create Post</h1>
                        </div>

                        {step === 'details' && (
                            <Button
                                onClick={handleSubmit}
                                disabled={uploading || !flowerName.trim()}
                            >
                                {uploading ? (
                                    <>
                                        <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                                        Posting...
                                    </>
                                ) : (
                                    'Post'
                                )}
                            </Button>
                        )}
                    </div>
                </div>
            </header>

            <main className="container mx-auto max-w-2xl px-4 py-6">
                {step === 'upload' && (
                    <ImageUploader
                        onImageSelect={handleImageSelect}
                        onImageRemove={handleImageRemove}
                        selectedImage={selectedImage}
                        previewUrl={previewUrl}
                    />
                )}

                {step === 'details' && (
                    <div className="space-y-6">
                        {/* Image Preview */}
                        <ImageUploader
                            onImageSelect={handleImageSelect}
                            onImageRemove={handleImageRemove}
                            selectedImage={selectedImage}
                            previewUrl={previewUrl}
                        />

                        {/* Flower Information */}
                        <Card>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2">
                                    <Sparkles className="h-5 w-5 text-yellow-500" />
                                    Flower Information
                                </CardTitle>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                <div className="space-y-2">
                                    <Label htmlFor="flower-name">
                                        Flower Name <span className="text-red-500">*</span>
                                    </Label>
                                    <Input
                                        id="flower-name"
                                        placeholder="e.g., Rose, Sunflower, Orchid"
                                        value={flowerName}
                                        onChange={(e) => setFlowerName(e.target.value)}
                                        required
                                    />
                                </div>

                                <div className="space-y-2">
                                    <Label htmlFor="description">Description</Label>
                                    <Textarea
                                        id="description"
                                        placeholder="Describe the flower's appearance, colors, characteristics..."
                                        value={flowerDescription}
                                        onChange={(e) => setFlowerDescription(e.target.value)}
                                        rows={3}
                                    />
                                </div>

                                <div className="space-y-2">
                                    <Label htmlFor="planting-guide">Planting Guide</Label>
                                    <Textarea
                                        id="planting-guide"
                                        placeholder="Share tips on how to grow and care for this flower..."
                                        value={plantingGuide}
                                        onChange={(e) => setPlantingGuide(e.target.value)}
                                        rows={4}
                                    />
                                </div>

                                <div className="space-y-2">
                                    <Label>AI Confidence: {aiConfidence}%</Label>
                                    <Slider
                                        value={[aiConfidence]}
                                        onValueChange={(value) => setAiConfidence(value[0])}
                                        min={0}
                                        max={100}
                                        step={1}
                                        className="w-full"
                                    />
                                    <p className="text-xs text-muted-foreground">
                                        How confident are you in the flower identification?
                                    </p>
                                </div>
                            </CardContent>
                        </Card>

                        {/* Post Details */}
                        <Card>
                            <CardHeader>
                                <CardTitle>Post Details</CardTitle>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                <div className="space-y-2">
                                    <Label htmlFor="caption">Caption</Label>
                                    <Textarea
                                        id="caption"
                                        placeholder="Write a caption for your post..."
                                        value={caption}
                                        onChange={(e) => setCaption(e.target.value)}
                                        rows={3}
                                    />
                                </div>

                                <div className="space-y-2">
                                    <MapboxLocationPicker
                                        value={locationName}
                                        onChange={setLocationName}
                                    />
                                </div>
                            </CardContent>
                        </Card>

                        {/* Submit Button (Mobile) */}
                        <Button
                            onClick={handleSubmit}
                            disabled={uploading || !flowerName.trim()}
                            className="w-full md:hidden"
                            size="lg"
                        >
                            {uploading ? (
                                <>
                                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                                    Posting...
                                </>
                            ) : (
                                'Post'
                            )}
                        </Button>
                    </div>
                )}
            </main>
        </div>
    );
}
