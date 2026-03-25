# Migrate TPL scraper to BiblioCommons

## Context

The old `torontopubliclibrary.ca/search.jsp` site is gone. The library
catalogue now lives at `tpl.bibliocommons.com`. The existing scraper is
broken because the old URLs and HTML structure no longer exist.

## New site details

- Base URL: `https://tpl.bibliocommons.com/v2/search`
- 20 results per page (was 150)
- Pagination: `&page=N` query parameter
- robots.txt requires 120-second crawl delay
- Book detail links: `/v2/record/XXXXX`

### HTML selectors (BiblioCommons)

| Data          | Selector                        | Example                       |
|---------------|---------------------------------|-------------------------------|
| Container     | `.search-result-item`           |                               |
| Title         | `.search-result-title a`        | "A Far-flung Life"            |
| Author        | `.search-result-author a`       | "Stedman, M. L."              |
| Year          | `.search-result-details`        | "Book, 2026"                  |
| Holds/copies  | `.search-result-holds`          | "Holds: 133 on 108 copies"   |
| Detail link   | `.search-result-title a[href]`  | `/v2/record/S234C4718441`     |

## Tasks

- [x] Create plan
- [x] Rewrite `lib/library.rb` for BiblioCommons URLs and selectors
- [x] Add 120-second crawl delay to `lib/utils.rb`
- [x] Update `views/book.erb` link base URL

## Improvement opportunities

(none yet)
