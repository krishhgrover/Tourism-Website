-- =============================================
--  WANDERLUST TOURS - Database Schema
-- =============================================
-- 1. Completely wipe out the old database so we start fresh
DROP DATABASE IF EXISTS wanderlust_db;
-- 2. Create a brand new, empty version of it
CREATE DATABASE wanderlust_db;
-- 3. Tell the computer to use this new empty one
USE wanderlust_db;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  avatar_url VARCHAR(255),
  passport_number VARCHAR(50),
  nationality VARCHAR(80),
  date_of_birth DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Destinations Table
CREATE TABLE IF NOT EXISTS destinations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  country VARCHAR(100) NOT NULL,
  continent VARCHAR(60),
  description TEXT,
  image_url VARCHAR(255),
  highlight_tag VARCHAR(60),
  avg_temp_celsius DECIMAL(4,1),
  best_months VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tour Packages Table
CREATE TABLE IF NOT EXISTS tour_packages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  destination_id INT,
  duration_days INT NOT NULL,
  price_per_person DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2),
  category ENUM('adventure','cultural','beach','wildlife','city','luxury','budget') NOT NULL,
  description TEXT,
  itinerary JSON,
  inclusions JSON,
  exclusions JSON,
  image_url VARCHAR(255),
  max_group_size INT DEFAULT 20,
  difficulty ENUM('easy','moderate','challenging') DEFAULT 'easy',
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INT DEFAULT 0,
  is_featured BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE SET NULL
);

-- Transport Options Table
CREATE TABLE IF NOT EXISTS transport_options (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type ENUM('flight','train','bus','cruise','car_rental') NOT NULL,
  provider VARCHAR(120) NOT NULL,
  origin VARCHAR(120) NOT NULL,
  destination VARCHAR(120) NOT NULL,
  departure_datetime DATETIME,
  arrival_datetime DATETIME,
  price DECIMAL(10,2) NOT NULL,
  class VARCHAR(30),
  seats_available INT,
  amenities JSON,
  logo_url VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bookings Table
CREATE TABLE IF NOT EXISTS bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_ref VARCHAR(20) UNIQUE NOT NULL,
  user_id INT NOT NULL,
  package_id INT,
  transport_id INT,
  check_in_date DATE,
  check_out_date DATE,
  num_adults INT DEFAULT 1,
  num_children INT DEFAULT 0,
  total_amount DECIMAL(10,2) NOT NULL,
  status ENUM('pending','confirmed','cancelled','completed') DEFAULT 'pending',
  special_requests TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (package_id) REFERENCES tour_packages(id) ON DELETE SET NULL,
  FOREIGN KEY (transport_id) REFERENCES transport_options(id) ON DELETE SET NULL
);

-- Payments Table
CREATE TABLE IF NOT EXISTS payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'USD',
  method ENUM('card','upi','netbanking','wallet','emi') NOT NULL,
  status ENUM('pending','success','failed','refunded') DEFAULT 'pending',
  transaction_id VARCHAR(100),
  gateway_response JSON,
  paid_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
);

-- Visa Applications Table
CREATE TABLE IF NOT EXISTS visa_applications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  destination_country VARCHAR(100) NOT NULL,
  visa_type ENUM('tourist','business','transit','student','work') DEFAULT 'tourist',
  passport_number VARCHAR(50) NOT NULL,
  travel_date DATE,
  status ENUM('draft','submitted','processing','approved','rejected') DEFAULT 'draft',
  documents_submitted JSON,
  notes TEXT,
  applied_at TIMESTAMP,
  decided_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Visa Requirements Table
CREATE TABLE IF NOT EXISTS visa_requirements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  country VARCHAR(100) NOT NULL,
  nationality VARCHAR(100) NOT NULL,
  visa_required BOOLEAN DEFAULT TRUE,
  visa_on_arrival BOOLEAN DEFAULT FALSE,
  e_visa_available BOOLEAN DEFAULT FALSE,
  processing_days INT,
  fee_usd DECIMAL(8,2),
  validity_days INT,
  max_stay_days INT,
  documents_required JSON,
  notes TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Reviews Table
CREATE TABLE IF NOT EXISTS reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  package_id INT NOT NULL,
  rating INT CHECK (rating BETWEEN 1 AND 5),
  title VARCHAR(150),
  body TEXT,
  images JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (package_id) REFERENCES tour_packages(id) ON DELETE CASCADE
);

-- =============================================
--  SEED DATA
-- =============================================

INSERT INTO destinations (name, country, continent, description, image_url, highlight_tag, avg_temp_celsius, best_months) VALUES
('Bali', 'Indonesia', 'Asia', 'A tropical paradise with stunning rice terraces, vibrant arts scene, and world-class surf.', 'https://www.johansens.com/wp-content/uploads/2016/08/Thailand-AYANA-Estate-Bali-73-e1673272835586.jpg', 'Tropical', 28.0, 'April–October'),
('Santorini', 'Greece', 'Europe', 'Iconic whitewashed clifftop villages with breathtaking caldera views and azure seas.', 'https://d2rdhxfof4qmbb.cloudfront.net/wp-content/uploads/2023/11/santorini-4825173_1280-1024x675.jpg', 'Romantic', 22.0, 'May–October'),
('Kyoto', 'Japan', 'Asia', 'Ancient capital of Japan with over 1,000 temples, geisha districts, and bamboo forests.', 'https://www.planetware.com/img/gallery/kyotos-10-most-amazing-tourist-attractions-to-add-to-your-itinerary/l-intro-1764346932.jpg', 'Cultural', 16.0, 'March–May'),
('Machu Picchu', 'Peru', 'South America', 'Majestic Inca citadel set high in the Andes mountains, a UNESCO World Heritage Site.', 'https://images.goway.com/production/styles/wide/s3/hero/iStock-1339071089.jpg.webp?VersionId=wh9Eb9ZGF3Srb6suNykdRW0Fat.4X9Ua&itok=ofMMTLit', 'Adventure', 14.0, 'May–October'),
('Maldives', 'Maldives', 'Asia', 'Crystal-clear lagoons, overwater bungalows, and some of the world''s finest coral reefs.', 'https://media.cntraveler.com/photos/66aa859b257a60dbb6105d8f/16:9/w_2560%2Cc_limit/Six%2520Senses%2520Kanuhura_The%2520Point%2520aerial.jpg', 'Luxury', 30.0, 'November–April'),
('Serengeti', 'Tanzania', 'Africa', 'Endless plains home to the Great Migration and one of nature''s most spectacular events.', 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800', 'Wildlife', 25.0, 'June–September'),
('Paris', 'France', 'Europe', 'The city of light, love, and fashion and home to the Eiffel Tower and world-class cuisine.', 'https://res.cloudinary.com/dtljonz0f/image/upload/c_fill,w_3840,g_auto/f_auto/q_auto:eco/v1/gc-v1/paris/paris_non-ed_shutterstock_2614817413_mncfps?_a=BAVAZGDY0', 'City', 15.0, 'April–October'),
('Queenstown', 'New Zealand', 'Oceania', 'Adventure capital of the world, set beside a glacial lake with the Remarkables as backdrop.', 'https://rtwin30days.com/wp-content/uploads/2012/02/Queenstown-Selects-87-1024x682.jpg', 'Adventure', 12.0, 'December–February');

INSERT INTO tour_packages (title, destination_id, duration_days, price_per_person, original_price, category, description, inclusions, image_url, max_group_size, difficulty, rating, review_count, is_featured) VALUES
('Bali Bliss Escape', 1, 7, 1299.00, 1599.00, 'beach', 'Seven days of pure paradise — rice terraces, temples, spa days, and sunset cocktails on the beach.', '["Return flights","5-star resort accommodation","Daily breakfast & 3 dinners","Private guided temple tours","Spa treatment session","Airport transfers"]', 'https://www.johansens.com/wp-content/uploads/2016/08/Thailand-AYANA-Estate-Bali-73-e1673272835586.jpg', 16, 'easy', 4.85, 312, TRUE),
('Santorini Romance', 2, 6, 2199.00, 2699.00, 'luxury', 'A curated lover''s journey through iconic caldera villages with private wine tastings and sunset sailings.', '["Business class flights","Luxury cave hotel","Daily breakfast","Private sailing tour","Wine tasting tour","Dinner at cliffside restaurant"]', 'https://d2rdhxfof4qmbb.cloudfront.net/wp-content/uploads/2023/11/santorini-4825173_1280-1024x675.jpg', 8, 'easy', 4.92, 198, TRUE),
('Kyoto Cultural Immersion', 3, 10, 2850.00, 3200.00, 'cultural', 'A deep dive into Japan''s soul — bamboo forests, tea ceremonies, geisha encounters, and sacred temple trails.', '["Return flights","Traditional ryokan stays","Daily breakfast","Tea ceremony class","Bamboo grove guided walk","JR Rail Pass","Zen garden meditation"]', 'https://www.planetware.com/img/gallery/kyotos-10-most-amazing-tourist-attractions-to-add-to-your-itinerary/l-intro-1764346932.jpg', 12, 'moderate', 4.78, 445, TRUE),
('Inca Trail Adventure', 4, 9, 1750.00, 2100.00, 'adventure', 'Hike the legendary Inca Trail to Machu Picchu, discovering ancient ruins and cloud-forest ecosystems.', '["Return flights","Trail camping & lodge mix","All meals on trail","Licensed Inca Trail guide","Entrance fees","Porter team","Emergency O2 kit"]', 'https://images.goway.com/production/styles/wide/s3/hero/iStock-1339071089.jpg.webp?VersionId=wh9Eb9ZGF3Srb6suNykdRW0Fat.4X9Ua&itok=ofMMTLit', 10, 'challenging', 4.80, 267, FALSE),
('Maldives Overwater Luxury', 5, 5, 3999.00, 4799.00, 'luxury', 'Five days of absolute indulgence — overwater bungalows, private butlers, and pristine reef snorkeling.', '["Seaplane transfer","Overwater villa","All-inclusive meals","Snorkeling & diving","Sunset dolphin cruise","Couples spa ritual","Personal butler"]', 'https://media.cntraveler.com/photos/66aa859b257a60dbb6105d8f/16:9/w_2560%2Cc_limit/Six%2520Senses%2520Kanuhura_The%2520Point%2520aerial.jpg', 4, 'easy', 4.95, 183, TRUE),
('Serengeti Safari Quest', 6, 8, 4500.00, 5200.00, 'wildlife', 'Witness the Great Migration up close — dawn game drives across golden plains with expert naturalists.', '["Return flights","Luxury tented camps","All meals","Daily game drives (AM & PM)","Night safari","Balloon safari","Expert wildlife guide"]', 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800', 8, 'moderate', 4.88, 221, TRUE),
('Paris City of Light', 7, 5, 1450.00, 1800.00, 'city', 'Five days exploring the finest of Paris — art, fashion, cuisine, and the magic of the Seine at dusk.', '["Return flights","4-star boutique hotel","Daily croissant breakfast","Skip-the-line Louvre access","Seine river dinner cruise","Eiffel Tower priority entry","Fashion district guided walk"]', 'https://res.cloudinary.com/dtljonz0f/image/upload/c_fill,w_3840,g_auto/f_auto/q_auto:eco/v1/gc-v1/paris/paris_non-ed_shutterstock_2614817413_mncfps?_a=BAVAZGDY0', 20, 'easy', 4.70, 389, FALSE),
('Queenstown Adrenaline Rush', 8, 6, 2100.00, 2500.00, 'adventure', 'Six action-packed days at the adventure capital of the world — bungee, skydiving, white-water, and more.', '["Return flights","Adventure lodge","Daily breakfast & dinner","Bungee jump (2x)","Skydive (tandem)","White-water rafting","Jet boat ride","Paragliding"]', 'https://rtwin30days.com/wp-content/uploads/2012/02/Queenstown-Selects-87-1024x682.jpg', 12, 'challenging', 4.82, 156, FALSE);

INSERT INTO visa_requirements (country, nationality, visa_required, visa_on_arrival, e_visa_available, processing_days, fee_usd, validity_days, max_stay_days, documents_required) VALUES
('Indonesia', 'Indian', FALSE, TRUE, TRUE, 1, 35.00, 30, 30, '["Valid passport", "Return ticket", "Hotel booking", "Proof of funds"]'),
('Greece', 'Indian', TRUE, FALSE, FALSE, 15, 80.00, 90, 90, '["Valid passport", "Schengen visa application", "Bank statement", "Travel insurance"]'),
('Japan', 'Indian', TRUE, FALSE, FALSE, 5, 0, 90, 30, '["Valid passport", "Visa application form", "Recent photos", "Bank statement"]'),
('Peru', 'Indian', FALSE, TRUE, FALSE, 0, 0, 183, 90, '["Valid passport", "Return ticket", "Proof of funds"]'),
('Maldives', 'Indian', FALSE, TRUE, FALSE, 0, 0, 30, 30, '["Valid passport", "Return ticket", "Hotel reservation", "Proof of funds"]'),
('Tanzania', 'Indian', TRUE, TRUE, TRUE, 1, 50.00, 90, 90, '["Valid passport", "Yellow fever certificate", "Return ticket", "Hotel booking"]'),
('France', 'Indian', TRUE, FALSE, FALSE, 15, 80.00, 90, 90, '["Valid passport", "Schengen application", "Travel insurance", "Bank statement"]'),
('New Zealand', 'Indian', TRUE, FALSE, TRUE, 7, 105.00, 9, 90, '["Valid passport", "NZeTA application", "Return ticket", "Proof of funds"]');
