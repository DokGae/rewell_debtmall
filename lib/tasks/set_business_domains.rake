namespace :business do
  desc "Set domain values for existing businesses based on their slug"
  task set_domains: :environment do
    Business.find_each do |business|
      if business.domain.blank?
        domain = business.slug || business.name.downcase.gsub(/[^a-z0-9\-]/, '-').gsub(/-+/, '-').gsub(/^-|-$/, '')
        
        # Ensure uniqueness
        base_domain = domain
        counter = 1
        while Business.where.not(id: business.id).exists?(domain: domain)
          domain = "#{base_domain}-#{counter}"
          counter += 1
        end
        
        business.update_column(:domain, domain)
        puts "Set domain for #{business.name}: #{domain}"
      end
    end
    
    puts "Domain setting completed!"
  end
end