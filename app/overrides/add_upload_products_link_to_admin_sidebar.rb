Deface::Override.new(
    virtual_path: 'spree/admin/shared/sub_menu/_product',
    name: 'add_upload_products_links_to_admin_sidebar',
    insert_bottom: '[data-hook="admin_product_sub_tabs"]',
    text: "<%= tab :upload_products, match_path: '/taxons' %>"
  )
  