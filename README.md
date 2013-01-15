# About
Prototype of a command line invoice generator that takes git commit input and spits out a .txt invoice. Also my first offline foray into OOB.

### Installation
<code>$ gem install invoices</code>

### Configuration
<code>$ invoices biller -n<br />
<code>$ invoices client -n<br />
<code>$ invoices invoice -c "Client Name"</code>

## TO DO LIST
- add 'init' CL command?
- Verify that there are records in the database
- Write Controller tests
- Prevent invalid data from being saved
- Improve CLI
- Validate data before stored to db
- Support MySQL & PostgreSQL
- Add custom error messages throughout (see comments)
  - Client names need to be in quotes (raise exception if they aren't)
- Allow commit messages to be > 40 characters
- Universalize testing of #project_root
- [Review sqlite3 gem methods](http://sqlite-ruby.rubyforge.org/sqlite3/)
- Allow multiple git repos per invoice
- Provide control over which commits get added to the invoice
- Add ability to regenerate invoices
- Add ability to preview invoices @ the command line
- Allow users to select where they want their invoices to be stored
- Export invoices as PDFs

### Bugs

### License
The MIT License (MIT)
Copyright (c) 2013 Aaron Macy (aaronmacy.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

