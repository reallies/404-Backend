-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('male', 'female', 'other', 'unknown');

-- CreateEnum
CREATE TYPE "AuthProvider" AS ENUM ('google', 'naver', 'kakao');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('booked', 'not_booked');

-- CreateEnum
CREATE TYPE "TripStatus" AS ENUM ('planning', 'preparing', 'completed');

-- CreateEnum
CREATE TYPE "FlightDirection" AS ENUM ('departure', 'return');

-- CreateEnum
CREATE TYPE "ChecklistStatus" AS ENUM ('not_started', 'preparing', 'completed');

-- CreateEnum
CREATE TYPE "ChecklistGeneratedBy" AS ENUM ('llm', 'template', 'hybrid');

-- CreateEnum
CREATE TYPE "PrepType" AS ENUM ('item', 'pre_booking', 'pre_departure_check', 'ai_recommend');

-- CreateEnum
CREATE TYPE "BaggageType" AS ENUM ('carry_on', 'checked', 'none');

-- CreateEnum
CREATE TYPE "ChecklistItemSource" AS ENUM ('llm', 'template', 'user_added');

-- CreateEnum
CREATE TYPE "EditType" AS ENUM ('text', 'add', 'del', 'reorder');

-- CreateEnum
CREATE TYPE "CheckAction" AS ENUM ('checked', 'unchecked');

-- CreateEnum
CREATE TYPE "LlmStatus" AS ENUM ('pending', 'success', 'failed');

-- CreateEnum
CREATE TYPE "UserEventType" AS ENUM ('search', 'detail_check', 'save', 'saved_list_open', 'edit_text', 'edit_add', 'edit_del', 'edit_reorder', 'prepare_action', 're_search', 'missing_item_detection');

-- CreateTable
CREATE TABLE "users" (
    "id" BIGSERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "nickname" TEXT NOT NULL,
    "profile_image_url" TEXT,
    "gender" "Gender" NOT NULL DEFAULT 'unknown',
    "birth_date" DATE,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_auth_providers" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "provider" "AuthProvider" NOT NULL,
    "provider_user_id" TEXT NOT NULL,
    "access_token_hash" TEXT NOT NULL,
    "linked_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_auth_providers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_passports" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "country_id" BIGINT NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "expires_at" DATE,

    CONSTRAINT "user_passports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "countries" (
    "id" BIGSERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name_ko" TEXT NOT NULL,
    "name_en" TEXT NOT NULL,

    CONSTRAINT "countries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cities" (
    "id" BIGSERIAL NOT NULL,
    "country_id" BIGINT NOT NULL,
    "name_ko" TEXT NOT NULL,
    "name_en" TEXT NOT NULL,
    "iata_code" TEXT,
    "is_served" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "cities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_categories" (
    "id" BIGSERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "label_ko" TEXT NOT NULL,
    "sort_order" INTEGER NOT NULL,

    CONSTRAINT "checklist_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "travel_styles" (
    "id" BIGSERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "label_ko" TEXT NOT NULL,
    "icon_path" TEXT NOT NULL,

    CONSTRAINT "travel_styles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "companion_types" (
    "id" BIGSERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "label_ko" TEXT NOT NULL,

    CONSTRAINT "companion_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trips" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "country_id" BIGINT NOT NULL,
    "title" TEXT NOT NULL,
    "trip_start" DATE NOT NULL,
    "trip_end" DATE NOT NULL,
    "booking_status" "BookingStatus" NOT NULL,
    "status" "TripStatus" NOT NULL DEFAULT 'planning',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "trips_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trip_cities" (
    "id" BIGSERIAL NOT NULL,
    "trip_id" BIGINT NOT NULL,
    "city_id" BIGINT NOT NULL,
    "order_index" INTEGER NOT NULL,
    "visit_start" DATE,
    "visit_end" DATE,
    "is_auto_synced" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "trip_cities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trip_flights" (
    "id" BIGSERIAL NOT NULL,
    "trip_id" BIGINT NOT NULL,
    "direction" "FlightDirection" NOT NULL,
    "flight_no" TEXT NOT NULL,
    "airline" TEXT NOT NULL,
    "departure_iata" TEXT NOT NULL,
    "arrival_iata" TEXT NOT NULL,
    "depart_at" TIMESTAMP(3) NOT NULL,
    "arrive_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "trip_flights_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trip_companions" (
    "id" BIGSERIAL NOT NULL,
    "trip_id" BIGINT NOT NULL,
    "companion_type_id" BIGINT NOT NULL,
    "has_pet" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "trip_companions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trip_travel_styles" (
    "id" BIGSERIAL NOT NULL,
    "trip_id" BIGINT NOT NULL,
    "travel_style_id" BIGINT NOT NULL,

    CONSTRAINT "trip_travel_styles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklists" (
    "id" BIGSERIAL NOT NULL,
    "trip_id" BIGINT NOT NULL,
    "status" "ChecklistStatus" NOT NULL DEFAULT 'not_started',
    "completion_rate" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "generated_by" "ChecklistGeneratedBy" NOT NULL,
    "generated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "checklists_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_items" (
    "id" BIGSERIAL NOT NULL,
    "checklist_id" BIGINT NOT NULL,
    "category_id" BIGINT NOT NULL,
    "template_id" BIGINT,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "detail" TEXT,
    "prep_type" "PrepType" NOT NULL,
    "baggage_type" "BaggageType" NOT NULL,
    "source" "ChecklistItemSource" NOT NULL,
    "order_index" INTEGER NOT NULL,
    "is_checked" BOOLEAN NOT NULL DEFAULT false,
    "checked_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "checklist_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_item_templates" (
    "id" BIGSERIAL NOT NULL,
    "category_id" BIGINT NOT NULL,
    "country_id" BIGINT,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "detail" TEXT,
    "prep_type" "PrepType" NOT NULL,
    "baggage_type" "BaggageType" NOT NULL,
    "conditions" JSONB NOT NULL,
    "is_essential" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "checklist_item_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "guide_archives" (
    "id" BIGSERIAL NOT NULL,
    "checklist_id" BIGINT NOT NULL,
    "name" TEXT NOT NULL,
    "snapshot" JSONB NOT NULL,
    "archived_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "guide_archives_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_item_edits" (
    "id" BIGSERIAL NOT NULL,
    "item_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "edit_type" "EditType" NOT NULL,
    "before_value" JSONB,
    "after_value" JSONB,
    "occurred_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "checklist_item_edits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_item_checks" (
    "id" BIGSERIAL NOT NULL,
    "item_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "action" "CheckAction" NOT NULL,
    "occurred_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "checklist_item_checks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "llm_generations" (
    "id" BIGSERIAL NOT NULL,
    "trip_id" BIGINT NOT NULL,
    "prompt_input" JSONB NOT NULL,
    "response_raw" JSONB,
    "model" TEXT NOT NULL,
    "tokens_used" INTEGER NOT NULL DEFAULT 0,
    "status" "LlmStatus" NOT NULL DEFAULT 'pending',
    "generated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "llm_generations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_events" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "trip_id" BIGINT,
    "item_id" BIGINT,
    "session_id" TEXT NOT NULL,
    "event_type" "UserEventType" NOT NULL,
    "metadata" JSONB,
    "occurred_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_events_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_deleted_at_idx" ON "users"("deleted_at");

-- CreateIndex
CREATE INDEX "user_auth_providers_user_id_idx" ON "user_auth_providers"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_auth_providers_provider_provider_user_id_key" ON "user_auth_providers"("provider", "provider_user_id");

-- CreateIndex
CREATE INDEX "user_passports_user_id_idx" ON "user_passports"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "countries_code_key" ON "countries"("code");

-- CreateIndex
CREATE INDEX "cities_country_id_idx" ON "cities"("country_id");

-- CreateIndex
CREATE INDEX "cities_iata_code_idx" ON "cities"("iata_code");

-- CreateIndex
CREATE UNIQUE INDEX "checklist_categories_code_key" ON "checklist_categories"("code");

-- CreateIndex
CREATE UNIQUE INDEX "travel_styles_code_key" ON "travel_styles"("code");

-- CreateIndex
CREATE UNIQUE INDEX "companion_types_code_key" ON "companion_types"("code");

-- CreateIndex
CREATE INDEX "trips_user_id_status_idx" ON "trips"("user_id", "status");

-- CreateIndex
CREATE INDEX "trips_deleted_at_idx" ON "trips"("deleted_at");

-- CreateIndex
CREATE INDEX "trip_cities_trip_id_order_index_idx" ON "trip_cities"("trip_id", "order_index");

-- CreateIndex
CREATE INDEX "trip_flights_trip_id_direction_idx" ON "trip_flights"("trip_id", "direction");

-- CreateIndex
CREATE UNIQUE INDEX "trip_companions_trip_id_companion_type_id_key" ON "trip_companions"("trip_id", "companion_type_id");

-- CreateIndex
CREATE UNIQUE INDEX "trip_travel_styles_trip_id_travel_style_id_key" ON "trip_travel_styles"("trip_id", "travel_style_id");

-- CreateIndex
CREATE UNIQUE INDEX "checklists_trip_id_key" ON "checklists"("trip_id");

-- CreateIndex
CREATE INDEX "checklist_items_checklist_id_order_index_idx" ON "checklist_items"("checklist_id", "order_index");

-- CreateIndex
CREATE INDEX "checklist_items_deleted_at_idx" ON "checklist_items"("deleted_at");

-- CreateIndex
CREATE INDEX "checklist_item_templates_category_id_idx" ON "checklist_item_templates"("category_id");

-- CreateIndex
CREATE INDEX "checklist_item_templates_country_id_idx" ON "checklist_item_templates"("country_id");

-- CreateIndex
CREATE INDEX "guide_archives_checklist_id_archived_at_idx" ON "guide_archives"("checklist_id", "archived_at");

-- CreateIndex
CREATE INDEX "checklist_item_edits_item_id_occurred_at_idx" ON "checklist_item_edits"("item_id", "occurred_at");

-- CreateIndex
CREATE INDEX "checklist_item_edits_user_id_occurred_at_idx" ON "checklist_item_edits"("user_id", "occurred_at");

-- CreateIndex
CREATE INDEX "checklist_item_checks_item_id_occurred_at_idx" ON "checklist_item_checks"("item_id", "occurred_at");

-- CreateIndex
CREATE INDEX "checklist_item_checks_user_id_occurred_at_idx" ON "checklist_item_checks"("user_id", "occurred_at");

-- CreateIndex
CREATE INDEX "llm_generations_trip_id_generated_at_idx" ON "llm_generations"("trip_id", "generated_at");

-- CreateIndex
CREATE INDEX "llm_generations_status_idx" ON "llm_generations"("status");

-- CreateIndex
CREATE INDEX "user_events_user_id_occurred_at_idx" ON "user_events"("user_id", "occurred_at");

-- CreateIndex
CREATE INDEX "user_events_session_id_idx" ON "user_events"("session_id");

-- CreateIndex
CREATE INDEX "user_events_event_type_occurred_at_idx" ON "user_events"("event_type", "occurred_at");

-- AddForeignKey
ALTER TABLE "user_auth_providers" ADD CONSTRAINT "user_auth_providers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_passports" ADD CONSTRAINT "user_passports_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_passports" ADD CONSTRAINT "user_passports_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "countries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cities" ADD CONSTRAINT "cities_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "countries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trips" ADD CONSTRAINT "trips_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trips" ADD CONSTRAINT "trips_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "countries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_cities" ADD CONSTRAINT "trip_cities_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_cities" ADD CONSTRAINT "trip_cities_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_flights" ADD CONSTRAINT "trip_flights_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_companions" ADD CONSTRAINT "trip_companions_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_companions" ADD CONSTRAINT "trip_companions_companion_type_id_fkey" FOREIGN KEY ("companion_type_id") REFERENCES "companion_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_travel_styles" ADD CONSTRAINT "trip_travel_styles_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_travel_styles" ADD CONSTRAINT "trip_travel_styles_travel_style_id_fkey" FOREIGN KEY ("travel_style_id") REFERENCES "travel_styles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklists" ADD CONSTRAINT "checklists_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_items" ADD CONSTRAINT "checklist_items_checklist_id_fkey" FOREIGN KEY ("checklist_id") REFERENCES "checklists"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_items" ADD CONSTRAINT "checklist_items_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "checklist_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_items" ADD CONSTRAINT "checklist_items_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "checklist_item_templates"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_item_templates" ADD CONSTRAINT "checklist_item_templates_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "checklist_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_item_templates" ADD CONSTRAINT "checklist_item_templates_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "countries"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "guide_archives" ADD CONSTRAINT "guide_archives_checklist_id_fkey" FOREIGN KEY ("checklist_id") REFERENCES "checklists"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_item_edits" ADD CONSTRAINT "checklist_item_edits_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "checklist_items"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_item_edits" ADD CONSTRAINT "checklist_item_edits_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_item_checks" ADD CONSTRAINT "checklist_item_checks_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "checklist_items"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_item_checks" ADD CONSTRAINT "checklist_item_checks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "llm_generations" ADD CONSTRAINT "llm_generations_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_events" ADD CONSTRAINT "user_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_events" ADD CONSTRAINT "user_events_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_events" ADD CONSTRAINT "user_events_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "checklist_items"("id") ON DELETE SET NULL ON UPDATE CASCADE;
