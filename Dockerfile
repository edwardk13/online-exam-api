# Sử dụng PHP 8.2 với Apache
FROM php:8.2-apache

# Cài đặt các thư viện cần thiết cho Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl

# Cài đặt các extension PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# Correct order:
WORKDIR /var/www/html

# 1. Copy composer files first
COPY composer.json composer.lock ./

# 2. Run composer install
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# 3. Copy the rest of the application
COPY . .
# Example of installing required extensions first
RUN apt-get update && apt-get install -y libzip-dev zip \
    && docker-php-ext-install zip pdo pdo_mysql

RUN composer install --no-interaction ...
RUN COMPOSER_MEMORY_LIMIT=-1 composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
# Thiết lập thư mục làm việc
WORKDIR /var/www/html

# Copy toàn bộ code vào container
COPY . .

# Cài đặt các gói phụ thuộc của Laravel (bỏ qua dev)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# Cấp quyền cho thư mục storage và bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Cấu hình Apache để trỏ vào thư mục public (quan trọng)
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# Bật rewrite mod của Apache (để chạy route Laravel)
RUN a2enmod rewrite

# Mở port 80
EXPOSE 80

