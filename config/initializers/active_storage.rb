# Active Storage 설정
Rails.application.config.after_initialize do
  # libvips가 없을 때 fallback 처리
  if defined?(ActiveStorage)
    ActiveStorage::Variation.class_eval do
      alias_method :original_transformations, :transformations
      
      def transformations
        # libvips가 없으면 원본 이미지 반환
        begin
          original_transformations
        rescue LoadError => e
          if e.message.include?('vips')
            Rails.logger.warn "libvips not available, returning original image"
            {}
          else
            raise e
          end
        end
      end
    end
  end
end