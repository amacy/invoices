class InvoicesController
  def initialize(client)
    @biller = Biller.new.default
    @invoice = Invoice.new
    @client = client
    @invoice.client_id = @client.id
    get_root
    add_line_items
    create_file
  end
  def get_root
    puts "Where is the project root (the parent directory of the git repo)?"
    @invoice.project_root($stdin.gets.chomp)
    @invoice.git_root
  end
  def add_line_items
    commits = CommitsController.new(@invoice.git_root).index
    LineItemsController.new(@invoice, commits, @client)
  end
  def create_file
    @invoice.save
    view = InvoicesView.new(@invoice, @biller, @client)
    File.open("#{INVOICES_FOLDER}/invoice#{@invoice.format_number}.txt", 'w') { |f| f.write(view.render) }
    puts "generated invoice#{@invoice.format_number}.txt"
  end
end
