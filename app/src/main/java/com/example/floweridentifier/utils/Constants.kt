package com.example.floweridentifier.utils

object Constants {
    
    // Cloudflare Tunnel URL - updates when cloudflared restarts
    // Backend API URL
    const val BASE_URL = "https://baptist-montreal-connector-thousands.trycloudflare.com/"
    const val DATABASE_NAME = "FLOWER"
    
    // Website URL for sharing posts
    // 1. Run the Next.js app: npm run dev
    // 2. Copy the ngrok URL and update WEB_SHARE_URL below
    // Example: const val WEB_SHARE_URL = "https://your-ngrok-url.ngrok-free.dev/upload"
    // For local testing (mobile device must be on same network): const val WEB_SHARE_URL = "http://YOUR_LOCAL_IP:3000/upload"
    const val WEB_SHARE_URL = "https://character-median-hitachi-salary.trycloudflare.com/upload"

    // Supabase Configuration
    const val SUPABASE_URL = "https://bdtrszhkuvslhadlnpbn.supabase.co"
    const val SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkdHJzemhrdXZzbGhhZGxucGJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY2MzkxMjEsImV4cCI6MjA4MjIxNTEyMX0.V6P8LG2GLCac7f-u3jiLAZcW-K86GWxjvJHpl1Xqjrw"

    val FLOWERS = mutableListOf(
        "bluebell", "Carnation", "Dahlia", "Forget-Me-Not", "Frangipani", "Jasmine", "Marigold", "Mimosa",
        "Orchid", "Zinnia", "astilbe", "bellflower", "black_eyed_susan", "buttercup", "calendula", "california_poppy",
        "cherryblossom", "coltsfoot", "cowslip", "crocus", "daffodil", "daisy", "dandelion", "fritillary",
        "iris", "lily", "lilyvalley", "magnolia" ,"pansy", "rose", "snowdrop", "sunflower",
        "tigerlily", "tulip", "water_lily", "windflower"
    )
}
