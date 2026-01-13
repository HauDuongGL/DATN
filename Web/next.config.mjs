/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    unoptimized: true,
  },
  webpack: (config, { isServer }) => {
    // Fix for Mapbox GL JS worker files
    if (!isServer) {
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false,
      }
    }
    return config
  },
  async rewrites() {
    return [
      {
        source: '/recognition',
        destination: 'http://127.0.0.1:5000/recognition',
      },
      {
        source: '/description/:path*',
        destination: 'http://127.0.0.1:5000/description/:path*',
      },
      {
        source: '/api/chat',
        destination: 'http://127.0.0.1:5000/chat',
      },
      // Proxy thêm các route chung nếu cần, nhưng cẩn thận loop
    ]
  },
}

export default nextConfig
