"use client"

import { useState, useEffect, useCallback } from "react"
import dynamic from "next/dynamic"
import { MapPin, Crosshair } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

// Dynamic import để tránh SSR issues với Mapbox
const Map = dynamic(
  () => import("react-map-gl/mapbox").then((mod) => mod.default),
  {
    ssr: false,
    loading: () => (
      <div className="flex h-full w-full items-center justify-center bg-gray-100">
        <p className="text-sm text-gray-600">Loading map...</p>
      </div>
    ),
  }
)

const Marker = dynamic(
  () => import("react-map-gl/mapbox").then((mod) => mod.Marker),
  { ssr: false }
)

const NavigationControl = dynamic(
  () => import("react-map-gl/mapbox").then((mod) => mod.NavigationControl),
  { ssr: false }
)

const GeolocateControl = dynamic(
  () => import("react-map-gl/mapbox").then((mod) => mod.GeolocateControl),
  { ssr: false }
)

interface MapboxLocationPickerProps {
  value: string
  onChange: (location: string) => void
  onCoordinatesChange?: (coordinates: { lat: number; lng: number } | null) => void
  className?: string
}

// Mapbox access token
// Token được lấy từ environment variable NEXT_PUBLIC_MAPBOX_TOKEN
// Fallback token (nếu không có trong env): pk.eyJ1IjoiaGF1ZHVvbmcyOTA4IiwiYSI6ImNtZXV1ZGwyZjBiNWcydXNoMzJocWpiNzYifQ.LhkCihZDGtJ0Lxsdv-ppfw
const MAPBOX_TOKEN = process.env.NEXT_PUBLIC_MAPBOX_TOKEN || "pk.eyJ1IjoiaGF1ZHVvbmcyOTA4IiwiYSI6ImNtZXV1ZGwyZjBiNWcydXNoMzJocWpiNzYifQ.LhkCihZDGtJ0Lxsdv-ppfw"

export function MapboxLocationPicker({
  value,
  onChange,
  onCoordinatesChange,
  className = "",
}: MapboxLocationPickerProps) {
  const [viewport, setViewport] = useState({
    latitude: 10.762622, // Default to Ho Chi Minh City
    longitude: 106.660172,
    zoom: 13,
  })
  const [marker, setMarker] = useState<{ lat: number; lng: number } | null>(null)
  const [isGettingLocation, setIsGettingLocation] = useState(false)
  const [address, setAddress] = useState(value || "")
  const [mapError, setMapError] = useState<string | null>(null)

  // Get user's current location
  const getUserLocation = useCallback(async () => {
    if (!navigator.geolocation) {
      setMapError("Geolocation is not supported by your browser")
      return
    }

    setIsGettingLocation(true)
    setMapError(null)

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude, longitude } = position.coords
        setViewport({
          latitude,
          longitude,
          zoom: 15,
        })
        setMarker({ lat: latitude, lng: longitude })

        // Reverse geocoding to get address
        await reverseGeocode(latitude, longitude)

        setIsGettingLocation(false)
      },
      (error) => {
        console.error("Error getting location:", error)
        setMapError("Unable to get your location. Please allow location access or click on the map.")
        setIsGettingLocation(false)
      }
    )
  }, [])

  // Reverse geocoding: convert coordinates to address
  const reverseGeocode = async (lat: number, lng: number) => {
    try {
      const response = await fetch(
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${lng},${lat}.json?access_token=${MAPBOX_TOKEN}&limit=1`
      )
      const data = await response.json()

      if (data.features && data.features.length > 0) {
        const placeName = data.features[0].place_name
        setAddress(placeName)
        onChange(placeName)
        if (onCoordinatesChange) {
          onCoordinatesChange({ lat, lng })
        }
      }
    } catch (error) {
      console.error("Reverse geocoding error:", error)
      // Fallback: use coordinates as address
      const fallbackAddress = `${lat.toFixed(6)}, ${lng.toFixed(6)}`
      setAddress(fallbackAddress)
      onChange(fallbackAddress)
      if (onCoordinatesChange) {
        onCoordinatesChange({ lat, lng })
      }
    }
  }

  // Handle map click
  const handleMapClick = useCallback(
    async (event: any) => {
      const { lngLat } = event
      const lat = lngLat.lat
      const lng = lngLat.lng

      setMarker({ lat, lng })
      await reverseGeocode(lat, lng)
    },
    [onChange, onCoordinatesChange]
  )

  // Handle address input change
  const handleAddressChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newAddress = e.target.value
    setAddress(newAddress)
    onChange(newAddress)
  }

  // Geocode address to coordinates (when user types address)
  const geocodeAddress = async (address: string) => {
    if (!address.trim()) return

    try {
      const response = await fetch(
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(address)}.json?access_token=${MAPBOX_TOKEN}&limit=1`
      )
      const data = await response.json()

      if (data.features && data.features.length > 0) {
        const [lng, lat] = data.features[0].center
        setViewport({
          latitude: lat,
          longitude: lng,
          zoom: 15,
        })
        setMarker({ lat, lng })
        if (onCoordinatesChange) {
          onCoordinatesChange({ lat, lng })
        }
      }
    } catch (error) {
      console.error("Geocoding error:", error)
    }
  }

  // Update address when value prop changes
  useEffect(() => {
    if (value && value !== address) {
      setAddress(value)
    }
  }, [value])

  // Check if Mapbox token is set
  if (!MAPBOX_TOKEN) {
    return (
      <div className={`rounded-lg border border-yellow-200 bg-yellow-50 p-4 ${className}`}>
        <p className="text-sm text-yellow-800">
          <strong>Mapbox token required:</strong> Please set NEXT_PUBLIC_MAPBOX_TOKEN in your .env file.
          Get your token at{" "}
          <a
            href="https://account.mapbox.com/access-tokens/"
            target="_blank"
            rel="noopener noreferrer"
            className="underline"
          >
            https://account.mapbox.com/access-tokens/
          </a>
        </p>
        <Input
          value={address}
          onChange={handleAddressChange}
          placeholder="Enter location manually"
          className="mt-2"
        />
      </div>
    )
  }

  return (
    <div className={`space-y-3 ${className}`}>
      {/* Address Input */}
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <Label htmlFor="location-address">Location</Label>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={getUserLocation}
            disabled={isGettingLocation}
            className="h-8 text-xs"
          >
            {isGettingLocation ? (
              <>
                <Crosshair className="mr-1 h-3 w-3 animate-spin" />
                Getting location...
              </>
            ) : (
              <>
                <Crosshair className="mr-1 h-3 w-3" />
                Use my location
              </>
            )}
          </Button>
        </div>
        <Input
          id="location-address"
          value={address}
          onChange={handleAddressChange}
          onBlur={() => geocodeAddress(address)}
          placeholder="Enter address or click on map"
          className="border-emerald-200 focus:border-emerald-500"
        />
        {mapError && (
          <p className="text-xs text-red-600">{mapError}</p>
        )}
      </div>

      {/* Map */}
      <div className="relative h-64 w-full overflow-hidden rounded-lg border border-emerald-200">
        <Map
          mapboxAccessToken={MAPBOX_TOKEN}
          {...viewport}
          onMove={(evt) => setViewport(evt.viewState)}
          onClick={handleMapClick}
          style={{ width: "100%", height: "100%" }}
          mapStyle="mapbox://styles/mapbox/streets-v12"
        >
          {marker && (
            <Marker
              latitude={marker.lat}
              longitude={marker.lng}
              anchor="bottom"
            >
              <div className="flex flex-col items-center">
                <MapPin className="h-6 w-6 text-red-500" fill="currentColor" />
              </div>
            </Marker>
          )}
          <NavigationControl position="top-right" />
          <GeolocateControl
            position="top-left"
            onGeolocate={(e: any) => {
              const { coords } = e
              setMarker({ lat: coords.latitude, lng: coords.longitude })
              reverseGeocode(coords.latitude, coords.longitude)
            }}
          />
        </Map>
      </div>
    </div>
  )
}
