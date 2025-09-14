FROM ghcr.io/cirruslabs/flutter:3.22.0 AS build
WORKDIR /app

RUN flutter config --enable-web
COPY pubspec.* ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY build/web . 
EXPOSE 80