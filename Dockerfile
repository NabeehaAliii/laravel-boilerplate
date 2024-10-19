# Base image
FROM php:8.2-apache
# Set working directory
WORKDIR /var/www/html
# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        libzip-dev \
        zip \
        unzip \
        libpng-dev \
        libonig-dev \
        libxml2-dev
# Enable Apache modules
RUN a2enmod rewrite
# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip
# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# Copy project files
COPY . .

# Create necessary directories
RUN mkdir -p /var/www/html/storage/framework/cache && \
    mkdir -p /var/www/html/storage/logs && \
    mkdir -p /var/www/html/bootstrap/cache


# Set file permissions
RUN chown -R www-data:www-data /var/www/html/storage
RUN chown -R www-data:www-data /var/www/html/bootstrap/cache

# Install project dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev
# Set up virtual host
COPY docker/vhost.conf /etc/apache2/sites-available/000-default.conf
# Expose port
EXPOSE 80
# Run Apache server
CMD ["apache2-foreground"]
