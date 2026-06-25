FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY pubspec.yaml .
COPY pubspec.lock* ./
RUN flutter pub get
COPY . .
RUN flutter create . --platforms web
RUN flutter build web --release --dart-define=API_BASE_URL=http://localhost:9084

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 9085
CMD ["nginx", "-g", "daemon off;"]
