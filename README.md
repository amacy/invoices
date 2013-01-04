# About
My first gem. Also my first offline foray into OOB.

### Installation
<code>gem install invoices</code>

# TO DO LIST
## v0.1.0
- Fix invoice.calculate_number / invoice.number / invoice_number
- Create InvoicesView; add initialize method & simplify call in generate_invoice
- Allow commit messages to be multiple lines
- Raise errors where noted (in comments)
- Add email field to billers & clients
- Write tests
- Add custom error messages throughout
- Turn into rubygem
- Write instructions

## v0.2.0
- Allow multiple git repos per invoice
- Provide control over which commits get added to the invoice
- Add ability to regenerate invoices
- Add ability to preview invoices @ the command line
- Allow users to select where they want their invoices to be stored

## Bugs
- CLI not prompting for first Commit.index date => msg pair in ~
- calculate_total_hrs/rate not working
- Client names need to be in quotes
