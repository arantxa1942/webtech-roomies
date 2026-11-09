module Api
  module V1
    class ListingsController < ActionController::API
      class InvalidFilter < StandardError; end

      rescue_from ActiveRecord::RecordNotFound, with: :listing_not_found
      rescue_from InvalidFilter, with: :invalid_filter

      def index
        listings = public_listings

        if params[:neighborhood_id].present?
          neighborhood_id = filter_text(:neighborhood_id)

          unless neighborhood_id.match?(/\A[1-9]\d*\z/)
            raise InvalidFilter, "neighborhood_id must be a positive integer."
          end

          listings = listings.in_neighborhood(neighborhood_id.to_i)
        end

        if params[:max_rent].present?
          rent_text = filter_text(:max_rent)

          unless rent_text.match?(/\A\d+(\.\d{1,2})?\z/)
            raise InvalidFilter, "max_rent must be a non-negative number with up to two decimals."
          end

          listings = listings.under_rent(BigDecimal(rent_text))
        end

        if params[:move_in_date].present?
          listings = listings.available_by(parse_move_in_date)
        end

        data = listings.order(:available_from, :id).map do |listing|
          listing_data(listing)
        end

        render json: {
          data: data,
          meta: { count: data.length }
        }, status: :ok
      end

      def show
        listing = public_listings.find(params[:id])

        render json: {
          data: listing_data(listing)
        }, status: :ok
      end

      private

      def public_listings
        Listing.published
               .with_attached_photos
               .includes(property: [:neighborhood, :amenities])
      end

      def listing_data(listing)
        property = listing.property
        neighborhood = property.neighborhood

        {
          id: listing.id,
          title: listing.title,
          monthly_rent: listing.monthly_rent.to_s("F"),
          deposit: listing.deposit&.to_s("F"),
          currency: "CLP",
          available_from: listing.available_from.iso8601,
          minimum_stay: listing.minimum_stay,
          furnished: listing.furnished,
          private_bathroom: listing.private_bathroom,
          status: listing.status,
          neighborhood: {
            id: neighborhood.id,
            name: neighborhood.name,
            city: neighborhood.city
          },
          property: {
            type: property.property_type,
            bedrooms: property.bedrooms,
            bathrooms: property.bathrooms,
            shared_spaces: property.shared_spaces
          },
          amenities: property.amenities.map do |amenity|
            {
              id: amenity.id,
              name: amenity.name,
              category: amenity.category
            }
          end,
          photo_url: card_photo_url(listing),
          listing_url: listing_url(listing)
        }
      end

      def card_photo_url(listing)
        return unless listing.photos.attached?

        url_for(listing.photos.first.variant(:card))
      end

      def filter_text(name)
        value = params[name]

        unless value.is_a?(String)
          raise InvalidFilter, "#{name} must be a single value."
        end

        value.strip
      end

      def parse_move_in_date
        value = filter_text(:move_in_date)

        unless value.match?(/\A\d{4}-\d{2}-\d{2}\z/)
          raise InvalidFilter, "move_in_date must use YYYY-MM-DD."
        end

        Date.iso8601(value)
      rescue Date::Error
        raise InvalidFilter, "move_in_date must be a valid date."
      end

      def listing_not_found
        render json: {
          error: {
            code: "not_found",
            message: "Published listing not found."
          }
        }, status: :not_found
      end

      def invalid_filter(exception)
        render json: {
          error: {
            code: "invalid_filter",
            message: exception.message
          }
        }, status: :bad_request
      end
    end
  end
end