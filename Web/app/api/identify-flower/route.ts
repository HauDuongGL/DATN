import { createClient } from "@/lib/supabase/server"
import { NextResponse } from "next/server"

export async function POST(request: Request) {
  try {
    const supabase = await createClient()

    // Verify authentication
    const {
      data: { user },
    } = await supabase.auth.getUser()

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const formData = await request.formData()
    const image = formData.get("image") as File

    if (!image) {
      return NextResponse.json({ error: "No image provided" }, { status: 400 })
    }

    // Convert image to base64
    const bytes = await image.arrayBuffer()
    const buffer = Buffer.from(bytes)
    const base64Image = buffer.toString("base64")

    // Mock AI identification response
    // In production, you would call a real AI API like Plant.id, PlantNet, or custom model
    const mockFlowers = [
      { name: "Rose", species: "Rosa", confidence: 95.5 },
      { name: "Tulip", species: "Tulipa", confidence: 92.3 },
      { name: "Sunflower", species: "Helianthus annuus", confidence: 98.7 },
      { name: "Daisy", species: "Bellis perennis", confidence: 88.4 },
      { name: "Orchid", species: "Orchidaceae", confidence: 91.2 },
      { name: "Lavender", species: "Lavandula", confidence: 89.6 },
      { name: "Chrysanthemum", species: "Chrysanthemum morifolium", confidence: 93.8 },
      { name: "Peony", species: "Paeonia", confidence: 87.1 },
    ]

    // Simulate AI processing delay
    await new Promise((resolve) => setTimeout(resolve, 1500))

    // Return random flower with confidence
    const randomFlower = mockFlowers[Math.floor(Math.random() * mockFlowers.length)]

    return NextResponse.json({
      success: true,
      result: {
        flower_name: randomFlower.name,
        flower_species: randomFlower.species,
        confidence: randomFlower.confidence,
        suggestions: mockFlowers.filter((f) => f.name !== randomFlower.name).slice(0, 3),
      },
    })
  } catch (error) {
    console.error("[v0] Flower identification error:", error)
    return NextResponse.json({ error: "Failed to identify flower" }, { status: 500 })
  }
}
