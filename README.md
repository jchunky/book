# Book

Scrapes the Toronto Public Library catalogue via the BiblioCommons
API and generates a sortable HTML report of books available at the
Parkdale branch.

## Usage

```
bundle install
ruby book.rb
open index.html
```

Results are cached in `.data/`. Delete cached files to re-fetch.
