FROM postgres:16

# Copy initialization scripts from your existing setup
COPY init.sql /docker-entrypoint-initdb.d/

# Set default database name (matches your docker-compose.yml)
ENV POSTGRES_DB=tasklistdb

# Health check (for Kubernetes readiness)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD pg_isready -U postgres -d tasklistdb || exit 1

# Expose port
EXPOSE 5432