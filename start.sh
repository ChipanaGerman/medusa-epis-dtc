#!/bin/sh
cd /server/apps/backend
echo "Running database migrations..."
pnpm medusa db:migrate
echo "Seeding database..."
pnpm seed || echo "Seeding failed, continuing..."
echo "Creating admin user..."
pnpm medusa user -e admin@test.com -p supersecret || echo "Admin user already exists or creation failed, continuing..."
echo "Starting Medusa development server..."
pnpm dev