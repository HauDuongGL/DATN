# Getting Started with FlowerShare

This guide will help you set up and start using your FlowerShare platform.

## For Administrators

### Initial Setup

1. **Create Your Admin Account**
   - Sign up at `/auth/sign-up`
   - Complete the onboarding flow
   - Your account is now ready!

2. **Grant Admin Access**
   - Go to your Supabase dashboard
   - Navigate to the SQL Editor
   - Run this query to make yourself an admin:
   ```sql
   INSERT INTO admin_users (id, role)
   VALUES ('your-user-id-here', 'admin');
   ```
   - Find your user ID in the `profiles` table

3. **Access Admin Dashboard**
   - Visit `/admin` after granting yourself admin access
   - Review pending posts
   - Monitor user reports
   - View platform statistics

### Managing Content

**Approving Posts:**
- Navigate to Admin Dashboard > Pending Posts
- Review each post for quality and appropriateness
- Click "Approve" to make it visible on the feed
- Click "Reject" to remove it (user will be notified)

**Handling Reports:**
- Check the Reports tab regularly
- Review reported content
- Take appropriate action (approve, reject, warn user)
- Mark reports as resolved

**Creating Groups:**
- Create groups for different flower types or topics
- Set groups as public or private
- Moderate group content and memberships

## For Users

### First Time Setup

1. **Create Account**
   - Go to FlowerShare homepage
   - Click "Get Started"
   - Enter your email and password
   - Verify your email

2. **Complete Onboarding**
   - Upload a profile picture (optional)
   - Add a bio about yourself
   - Select your interests
   - Choose your favorite flowers
   - Click "Complete Setup"

3. **Explore the Feed**
   - Browse beautiful flower posts
   - Like posts you enjoy
   - Comment to engage with others
   - Follow users you find interesting

### Posting Flowers

1. **Upload a Photo**
   - Click "Share Flower" or the + button
   - Select up to 5 photos
   - Add a caption describing your flower
   - Tag the location (optional)

2. **Use AI Identification**
   - Click "Identify Flower with AI"
   - The AI will suggest species names
   - Review and edit the suggestion
   - Add scientific name if known

3. **Submit for Review**
   - Click "Share Post"
   - Your post goes to moderation
   - You'll receive a notification when approved
   - View your post in the feed!

### Engaging with Community

**Following Users:**
- Visit any user's profile
- Click "Follow" button
- See their posts in your feed
- View follower/following counts

**Joining Groups:**
- Browse groups at `/groups`
- Click "Join Group" for public groups
- Request to join private groups
- Participate in group discussions

**Messaging:**
- Click the message icon
- Search for users
- Start a conversation
- Receive real-time messages

### Profile Customization

1. **Edit Your Profile**
   - Go to Settings
   - Update display name and bio
   - Change profile picture
   - Save changes

2. **Privacy Settings**
   - Control who can see your posts
   - Manage notifications
   - Update email preferences

## Tips for Best Experience

### Photography Tips
- Use natural lighting
- Focus on the flower details
- Include the whole plant when possible
- Show unique features or patterns
- Capture multiple angles

### Writing Great Captions
- Share the story behind the photo
- Include growing conditions
- Mention the location context
- Add care tips or interesting facts
- Use descriptive language

### Building Your Network
- Engage with comments regularly
- Share knowledge generously
- Follow users with similar interests
- Join relevant groups
- Post consistently

### Using AI Identification
- Upload clear, well-lit photos
- Focus on distinctive features
- Cross-reference AI suggestions
- Verify with botanical resources
- Share corrections if AI is wrong

## Common Tasks

### Change Your Password
1. Go to Settings
2. Click "Change Password"
3. Enter current and new password
4. Save changes

### Report Inappropriate Content
1. Click the three-dot menu on any post
2. Select "Report"
3. Choose a reason
4. Submit report
5. Admins will review

### Leave a Group
1. Go to the group page
2. Click "Leave Group"
3. Confirm your decision

### Delete a Post
1. Go to your profile
2. Find the post
3. Click the three-dot menu
4. Select "Delete"
5. Confirm deletion

## Troubleshooting

### Email Not Received
- Check spam/junk folder
- Verify email address is correct
- Request a new verification email
- Contact support if issue persists

### Upload Issues
- Check image file size (max 10MB)
- Ensure stable internet connection
- Try different browser
- Clear browser cache

### Can't See Messages
- Refresh the page
- Check internet connection
- Verify user hasn't blocked you
- Contact support

### Profile Not Updating
- Clear browser cache
- Log out and log back in
- Try different browser
- Check if changes were saved

## Need Help?

- Review the documentation in `/docs`
- Check FAQ section
- Contact administrators
- Visit support page

---

Welcome to the FlowerShare community! Happy sharing!
