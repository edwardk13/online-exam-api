# Sử dụng PHP 8.2 kèm Apache
FROM php:8.2-apache

# Cài đặt các thư viện hệ thống và PHP extensions cần thiết cho Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip xml

# Bật Apache mod_rewrite để chạy route của Laravel
RUN a2enmod rewrite

# Thiết lập thư mục làm việc trong Docker
WORKDIR /var/www/html

# COPY TOÀN BỘ CODE VÀO TRƯỚC (Bao gồm cả file artisan) để tránh lỗi post-autoload-dump
COPY . .

# Copy Composer từ image chính thức
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Chạy Composer install (Thêm COMPOSER_MEMORY_LIMIT=-1 để tránh lỗi thiếu RAM)
RUN COMPOSER_MEMORY_LIMIT=-1 composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# Phân quyền cho các thư mục cache và storage của Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Trỏ thư mục gốc của Apache vào thư mục "public" của Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
