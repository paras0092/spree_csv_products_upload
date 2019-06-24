Spree::Admin::ProductsController.class_eval do
    def upload_products
        ActiveRecord::Base.transaction do
            uploaded_file = params[:file]
            importer = Importers::ProductUpload.new(uploaded_file.open)
            importer.import
            @imported = importer.imported
            if !@imported.blank?
                flash[:error] = @imported[0]
                redirect_to admin_upload_products_path
            end            
        end
    end    
end