require 'csv'
module Importers
    class ProductUpload
        attr_accessor :file, :imported

        def initialize(file)
            @file = file
        end

        def import
            check = true
            @imported = []
            CSV.foreach(@file, headers: :true,skip_lines: /^(?:;\s*)+$/,:col_sep => ?;).each do |line| 
                # Check before creating product for existing slugs
                if(check == true && validate_slug == true)
                    @imported << "#{line['slug']} Slug is already present please use different one"
                    break                      
                end
                # Validate price field cannot be blank
                if(check == true &&  validate_price == true)
                    @imported << "Price column could not be blank" 
                    break
                end
              
                check = false

                name = line['name']
                description = line['description']
                price = line['price']
                availability_date = line['availability_date']
                slug = line['slug']
                stock_total = line['stock_total']
                category = line['category']
                create_new_product(name,description,price,availability_date,slug,stock_total,category) 

            end
        end

        protected

        def create_new_product(name,description,price,availability_date,slug,stock_total,category)            
            product = Spree::Product.new
            product.name = name
            product.description = description
            product.price = price.to_d
            product.available_on =  availability_date
            product.slug = slug
            product.shipping_category_id = 1 # set default shipping category                  
            product.save!
            if Spree::Taxonomy.all.map{|t| t.name}.include? category
                product.update(taxons: [Spree::Taxon.find_by_name(category)])
            else
                Spree::Taxonomy.create(name: category)
                product.update(taxons: [Spree::Taxon.find_by_name(category)])
            end 
            product.stock_items.first.update(count_on_hand: stock_total.to_i) #adding stock for default stock loction            
            
        end    
        
        # Function for validating slugs
        def validate_slug            
            CSV.foreach(@file, headers: :true,skip_lines: /^(?:;\s*)+$/,:col_sep => ?;).each do |line|
               return Spree::Product.all.map{|p| p.slug}.include? line['slug'] 
            end
        end

        #   Function for checking empty price from CSV
        def validate_price            
            CSV.foreach(@file, headers: :true,skip_lines: /^(?:;\s*)+$/,:col_sep => ?;).each do |line|
                return line['price'].blank?
            end
        end
    end
end