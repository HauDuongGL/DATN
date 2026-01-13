-- Insert sample users (these will be visible to everyone)
-- Note: These are placeholder profiles. In production, users will sign up through the auth system.

insert into profiles (id, email, display_name, bio, avatar_url, onboarding_completed, interests, favorite_flowers) values
  ('00000000-0000-0000-0000-000000000001', 'sarah@flowershare.com', 'Sarah Botanist', 'Passionate about rare orchids and sustainable gardening. Sharing my 15 years of botanical expertise!', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah', true, ARRAY['botany', 'photography', 'conservation'], ARRAY['Orchids', 'Lilies', 'Roses']),
  ('00000000-0000-0000-0000-000000000002', 'mike@flowershare.com', 'Mike Gardens', 'Urban gardener and flower photographer. Love capturing the beauty of nature in cities.', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Mike', true, ARRAY['gardening', 'photography'], ARRAY['Sunflowers', 'Tulips', 'Daisies']),
  ('00000000-0000-0000-0000-000000000003', 'emma@flowershare.com', 'Emma Rose', 'Rose enthusiast and landscape designer. Creating beautiful gardens one flower at a time.', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Emma', true, ARRAY['landscaping', 'gardening'], ARRAY['Roses', 'Peonies', 'Hydrangeas']),
  ('00000000-0000-0000-0000-000000000004', 'david@flowershare.com', 'David Bloom', 'Wildflower expert and nature conservationist. Protecting native species is my passion.', 'https://api.dicebear.com/7.x/avataaars/svg?seed=David', true, ARRAY['conservation', 'education', 'botany'], ARRAY['Lavender', 'Jasmine', 'Daisies']),
  ('00000000-0000-0000-0000-000000000005', 'lisa@flowershare.com', 'Lisa Petals', 'Florist and wedding designer. Turning flower dreams into reality!', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lisa', true, ARRAY['gardening', 'photography'], ARRAY['Peonies', 'Roses', 'Carnations'])
on conflict (id) do nothing;

-- Insert sample posts (already approved for demonstration)
insert into posts (id, author_id, caption, flower_name, flower_species, location, status) values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Found this stunning Phalaenopsis in the rainforest! The intricate patterns are absolutely mesmerizing.', 'Moth Orchid', 'Phalaenopsis amabilis', 'Borneo Rainforest', 'approved'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'My rooftop garden is thriving this spring! These sunflowers bring so much joy to the city skyline.', 'Sunflower', 'Helianthus annuus', 'Brooklyn, NY', 'approved'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'Just finished designing this rose garden for a lovely couple. The fragrance is incredible!', 'Hybrid Tea Rose', 'Rosa hybrid', 'Portland, OR', 'approved'),
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000004', 'Discovered a rare wild lupine meadow today. Conservation efforts are paying off!', 'Wild Lupine', 'Lupinus perennis', 'Montana Wilderness', 'approved'),
  ('10000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000005', 'Wedding bouquet prep! Peonies and roses are always a winning combination.', 'Peony Mix', 'Paeonia lactiflora', 'Seattle, WA', 'approved'),
  ('10000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000001', 'My award-winning orchid collection. These beauties took 3 years to bloom perfectly!', 'Cattleya Orchid', 'Cattleya labiata', 'My Greenhouse', 'approved'),
  ('10000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000002', 'Urban gardening tip: Tulips thrive in containers! Here is my balcony garden transformation.', 'Dutch Tulips', 'Tulipa gesneriana', 'Manhattan, NY', 'approved'),
  ('10000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000003', 'Garden hydrangeas changing color with soil pH. Science meets beauty!', 'Hydrangea', 'Hydrangea macrophylla', 'My Garden', 'approved')
on conflict (id) do nothing;

-- Insert sample post media (using placeholder images)
insert into post_media (post_id, media_url, media_type, display_order) values
  ('10000000-0000-0000-0000-000000000001', '/placeholder.svg?height=800&width=800', 'image', 1),
  ('10000000-0000-0000-0000-000000000002', '/placeholder.svg?height=800&width=800', 'image', 1),
  ('10000000-0000-0000-0000-000000000003', '/placeholder.svg?height=800&width=800', 'image', 1),
  ('10000000-0000-0000-0000-000000000004', '/placeholder.svg?height=800&width=800', 'image', 1),
  ('10000000-0000-0000-0000-000000000005', '/placeholder.svg?height=800&width=800', 'image', 1),
  ('10000000-0000-0000-0000-000000000006', '/placeholder.svg?height=800&width=800', 'image', 1),
  ('10000000-0000-0000-0000-000000000007', '/placeholder.svg?height=800&width=800', 'image', 1),
  ('10000000-0000-0000-0000-000000000008', '/placeholder.svg?height=800&width=800', 'image', 1)
on conflict do nothing;

-- Insert sample comments
insert into comments (post_id, author_id, content) values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Absolutely stunning! The detail in those petals is incredible. What camera did you use?'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', 'I have been trying to grow Phalaenopsis for years. Any tips?'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'Love seeing urban gardening success stories! Inspiring work!'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000005', 'The color palette is perfect! Would love to collaborate on a project.'),
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'Conservation work like this is so important. Thank you for sharing!'),
  ('10000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'Beautiful bouquet! The color combination is timeless.'),
  ('10000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000004', '3 years of patience really paid off! Magnificent blooms.'),
  ('10000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000005', 'Container gardening is the future of urban spaces. Great work!')
on conflict do nothing;

-- Insert sample likes
insert into likes (post_id, user_id) values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004'),
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000002'),
  ('10000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000003')
on conflict do nothing;

-- Insert sample follows
insert into follows (follower_id, following_id) values
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002'),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003'),
  ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004'),
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003')
on conflict do nothing;

-- Insert sample groups
insert into groups (id, name, description, is_private, created_by) values
  ('20000000-0000-0000-0000-000000000001', 'Orchid Lovers Club', 'A community for orchid enthusiasts to share growing tips, rare finds, and beautiful blooms!', false, '00000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000002', 'Urban Gardening', 'City dwellers sharing creative solutions for growing flowers in small spaces.', false, '00000000-0000-0000-0000-000000000002'),
  ('20000000-0000-0000-0000-000000000003', 'Rose Garden Society', 'Dedicated to the cultivation and appreciation of roses in all varieties.', false, '00000000-0000-0000-0000-000000000003'),
  ('20000000-0000-0000-0000-000000000004', 'Wildflower Conservation', 'Protecting and preserving native wildflower species through education and action.', false, '00000000-0000-0000-0000-000000000004')
on conflict (id) do nothing;

-- Insert sample group members
insert into group_members (group_id, user_id, role) values
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'member'),
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', 'member'),
  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'member'),
  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'member'),
  ('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000005', 'member'),
  ('20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'member')
on conflict do nothing;
