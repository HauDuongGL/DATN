/**
 * Image Uploader Component
 * Drag & drop image upload with preview
 */

'use client';

import { useState, useCallback } from 'react';
import { Upload, X, Image as ImageIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import Image from 'next/image';

interface ImageUploaderProps {
    onImageSelect: (file: File) => void;
    onImageRemove: () => void;
    selectedImage?: File | null;
    previewUrl?: string | null;
}

export function ImageUploader({
    onImageSelect,
    onImageRemove,
    selectedImage,
    previewUrl
}: ImageUploaderProps) {
    const [isDragging, setIsDragging] = useState(false);

    const handleDragOver = useCallback((e: React.DragEvent) => {
        e.preventDefault();
        setIsDragging(true);
    }, []);

    const handleDragLeave = useCallback((e: React.DragEvent) => {
        e.preventDefault();
        setIsDragging(false);
    }, []);

    const handleDrop = useCallback((e: React.DragEvent) => {
        e.preventDefault();
        setIsDragging(false);

        const files = Array.from(e.dataTransfer.files);
        const imageFile = files.find(file => file.type.startsWith('image/'));

        if (imageFile) {
            onImageSelect(imageFile);
        }
    }, [onImageSelect]);

    const handleFileInput = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file && file.type.startsWith('image/')) {
            onImageSelect(file);
        }
    }, [onImageSelect]);

    if (previewUrl || selectedImage) {
        return (
            <Card className="overflow-hidden">
                <CardContent className="p-0 relative">
                    <div className="relative aspect-square w-full">
                        <Image
                            src={previewUrl || URL.createObjectURL(selectedImage!)}
                            alt="Preview"
                            fill
                            className="object-cover"
                        />
                    </div>
                    <Button
                        variant="destructive"
                        size="icon"
                        className="absolute top-2 right-2"
                        onClick={onImageRemove}
                    >
                        <X className="h-4 w-4" />
                    </Button>
                </CardContent>
            </Card>
        );
    }

    return (
        <Card
            className={`border-2 border-dashed transition-colors ${isDragging ? 'border-primary bg-primary/5' : 'border-muted-foreground/25'
                }`}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
        >
            <CardContent className="p-12">
                <div className="flex flex-col items-center justify-center text-center space-y-4">
                    <div className="p-4 rounded-full bg-muted">
                        <ImageIcon className="h-8 w-8 text-muted-foreground" />
                    </div>

                    <div className="space-y-2">
                        <h3 className="font-semibold">Upload flower image</h3>
                        <p className="text-sm text-muted-foreground">
                            Drag and drop or click to browse
                        </p>
                    </div>

                    <label htmlFor="image-upload">
                        <Button type="button" asChild>
                            <span className="cursor-pointer">
                                <Upload className="h-4 w-4 mr-2" />
                                Choose Image
                            </span>
                        </Button>
                    </label>

                    <input
                        id="image-upload"
                        type="file"
                        accept="image/*"
                        className="hidden"
                        onChange={handleFileInput}
                    />

                    <p className="text-xs text-muted-foreground">
                        Supported formats: JPG, PNG, WebP (Max 10MB)
                    </p>
                </div>
            </CardContent>
        </Card>
    );
}
