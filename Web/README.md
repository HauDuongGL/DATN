# FlowerShare - Social Network for Flower Enthusiasts

A beautiful and feature-rich social media platform for flower lovers to share, discover, and identify flowers using AI technology.

## Features

### Core Features
- **User Authentication**: Secure email/password authentication with Supabase Auth
- **Onboarding Flow**: Personalized setup for new users with interests and preferences
- **Social Feed**: Browse approved flower posts with likes, comments, and interactions
- **Post Upload**: Share flower photos with captions, location, and AI identification
  - Interactive Mapbox location picker with map visualization
  - Get current location automatically or select on map
  - Reverse geocoding to convert coordinates to addresses
- **AI Flower Recognition**: Identify flower species using integrated AI services
- **User Profiles**: Customizable profiles with avatar, bio, and flower preferences
- **Follow System**: Follow other users and build your network

### Community Features
- **Groups & Communities**: Create or join flower-focused groups
  - Public and private groups
  - Group-specific posts and discussions
  - Admin/moderator roles
  - Join request approval for private groups
- **Real-time Messaging**: Direct 1-on-1 chat with other members
  - Conversation list with unread counts
  - Real-time message delivery
  - Search conversations

### Moderation
- **Admin Dashboard**: Comprehensive moderation tools
  - Review and approve pending posts
  - Manage user reports
  - Send notifications to users
  - View platform statistics

## Tech Stack

### Frontend
- **Next.js 16**: React framework with App Router
- **TypeScript**: Type-safe development
- **Tailwind CSS v4**: Modern utility-first styling
- **shadcn/ui**: Beautiful, accessible component library

### Backend & Database
- **Supabase**: Complete backend solution
  - PostgreSQL database with Row Level Security (RLS)
  - Authentication system
  - Storage for avatars and post images
  - Real-time subscriptions for chat

### AI Integration
- **Vercel AI SDK**: AI-powered flower recognition
- Ready to integrate with Plant.id, PlantNet, or custom models

## Database Schema

### Main Tables
- `profiles`: User information and preferences
- `posts`: Flower posts with status (pending/approved/rejected)
- `post_media`: Multiple images per post
- `comments`: Nested comments with replies
- `likes`: Likes for posts and comments
- `follows`: User follow relationships
- `notifications`: System and user notifications

### Groups & Communities
- `groups`: Community groups with public/private settings
- `group_members`: Membership with roles (admin/moderator/member)
- `group_posts`: Posts shared in groups
- `group_join_requests`: Join requests for private groups

### Messaging
- `conversations`: Chat threads between users
- `conversation_participants`: Participants in each conversation
- `messages`: Chat messages with real-time delivery

### Moderation
- `admin_users`: Admin access control
- `reports`: User reports for content moderation

## Getting Started

### Prerequisites
- Node.js 18+ installed
- A Supabase account (free tier works great)
- Vercel account (optional, for deployment)

### Installation

1. Clone and install dependencies:
```bash
npm install
```

2. Set up environment variables:
All environment variables are automatically configured through v0's Supabase integration.

3. Run database migrations:
All SQL scripts in the `scripts/` folder will be automatically executed to set up your database schema.

4. Start the development server:
```bash
npm run dev
```

5. Open [http://localhost:3000](http://localhost:3000)

### Seed Data
The project includes sample data (users, posts, comments, likes, groups) to help you explore the platform immediately. The seed script (`019_seed_sample_data.sql`) creates:
- 5 sample users with complete profiles
- 8 approved flower posts with images
- Comments and likes on posts
- Follow relationships
- 4 community groups with members

## Project Structure

```
├── app/
│   ├── auth/              # Authentication pages (login, sign-up)
│   ├── feed/              # Main social feed
│   ├── upload/            # Post upload page
│   ├── post/[id]/         # Individual post detail
│   ├── profile/[id]/      # User profiles
│   ├── settings/          # User settings
│   ├── groups/            # Groups listing and detail
│   ├── messages/          # Chat and messaging
│   ├── admin/             # Admin dashboard
│   ├── onboarding/        # New user onboarding
│   └── api/               # API routes (flower identification)
├── components/
│   ├── auth/              # Auth components (login forms, user menu)
│   ├── feed/              # Feed components (post cards, filters)
│   ├── upload/            # Upload form and AI identification
│   ├── post/              # Post detail, comments
│   ├── profile/           # Profile components
│   ├── groups/            # Group components
│   ├── messages/          # Chat components
│   ├── admin/             # Admin components
│   └── ui/                # shadcn/ui components
├── lib/
│   ├── supabase/          # Supabase client setup
│   ├── auth/              # Auth utilities
│   └── ai/                # AI flower recognition
└── scripts/               # Database migration scripts
```

## Key Features Implementation

### Row Level Security (RLS)
All database tables are protected with RLS policies:
- Users can only modify their own data
- Posts are visible based on approval status
- Group content restricted to members
- Messages only visible to conversation participants

### Real-time Updates
- Chat messages update instantly using Supabase Realtime
- Conversation list updates when new messages arrive
- Live notifications for interactions

### AI Flower Recognition
The platform includes a flexible AI integration system:
- Mock API for development/demo
- Easy integration with Plant.id, PlantNet, or custom models
- Confidence scores and species information
- Integration documentation included

### Image Upload & Storage
- Supabase Storage for avatars and post images
- Multiple images per post (up to 5)
- Automatic image optimization
- Public URL generation

## Deployment

### Deploy to Vercel (Recommended)
1. Push your code to GitHub
2. Connect your repository to Vercel
3. Vercel will automatically detect Next.js and configure settings
4. Add your Supabase environment variables in Vercel dashboard
5. Deploy!

The app is optimized for Vercel's Edge Network with:
- Automatic HTTPS
- Global CDN
- Serverless functions
- Built-in analytics

## Environment Variables

All required environment variables are managed through v0's Supabase integration:

- `NEXT_PUBLIC_SUPABASE_URL`: Your Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Supabase anonymous key
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key (for admin operations)
- `NEXT_PUBLIC_DEV_SUPABASE_REDIRECT_URL`: Dev redirect URL for email auth
- `NEXT_PUBLIC_MAPBOX_TOKEN`: Mapbox access token for location picker (get at https://account.mapbox.com/access-tokens/)

## Contributing

This project was built with v0 by Vercel. Feel free to customize and extend it for your needs!

## License

MIT License - feel free to use this project for personal or commercial purposes.

## Support

For issues or questions:
- Check the documentation in `docs/` folder
- Review Supabase documentation: https://supabase.com/docs
- Next.js documentation: https://nextjs.org/docs

---

Built with love for flower enthusiasts worldwide 🌸
