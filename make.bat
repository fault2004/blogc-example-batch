@ECHO OFF
setlocal EnableDelayedExpansion 

REM  - Configuration ---------------------------------------------------
set "author_name="Author""
set "author_email="author@example.org""
set "site_title="Site Title""
set "site_tagline="Site Tagline""

set "output_dir=_build"

set "BASE_DOMAIN="http://example.org""
set "BASE_URL="""

set "POST_PER_PAGE=10"
set "POST_PER_PAGE_ATOM=10"

set "DATE_FORMAT="%%b %%d, %%Y, %%I:%%M %%p GMT""
set "DATE_FORMAT_ATOM="%%Y-%%m-%%dT%%H:%%M:%%SZ""


REM  - Create output folder --------------------------------------------
rmdir /S /Q %output_dir%
mkdir %output_dir%


REM  - Copy assets -----------------------------------------------------
mkdir %output_dir%\assets
xcopy /e assets\* %output_dir%\assets


REM  - Post list variables ---------------------------------------------
set posts_list=
for %%i in (content\post\*.txt) do (
	set "posts_list=!posts_list! %%i"
)
echo !posts_list!


REM  - Generate first index page ---------------------------------------
echo generating first index page
blogc -D AUTHOR_NAME=%author_name% ^
-D AUTHOR_EMAIL=%author_email% ^
-D SITE_TITLE=%site_title% ^
-D SITE_TAGLINE=%site_tagline% ^
-D BASE_DOMAIN=%BASE_DOMAIN% ^
-D BASE_URL=%BASE_URL% ^
-D DATE_FORMAT=%DATE_FORMAT% ^
-D FILTER_PAGE=1 ^
-D FILTER_PER_PAGE=%POST_PER_PAGE% ^
-l -o %output_dir%\index.html -t templates\main.tmpl !posts_list!


REM  - Generate post content pages and next index pages ----------------
mkdir %output_dir%\post
set count=
set count_p=1
for %%i in (content\post\*.txt) do (
	blogc -D AUTHOR_NAME=%author_name% ^
	-D AUTHOR_EMAIL=%author_email% ^
	-D SITE_TITLE=%site_title% ^
	-D SITE_TAGLINE=%site_tagline% ^
	-D BASE_DOMAIN=%BASE_DOMAIN% ^
	-D BASE_URL=%BASE_URL% ^
	-D DATE_FORMAT=%DATE_FORMAT% ^
	-D FILTER_PAGE=1 ^
	-D FILTER_PER_PAGE=%POST_PER_PAGE% ^
	-D IS_POST=1 ^
	-o %output_dir%\post\%%~ni\index.html -t templates\main.tmpl %%i
	set /a count += 1
	echo post page: !count!

	REM  - Generate next index page ------------------------------------
	if !count_p!==!count! (
		echo index page: !count_p!
		blogc -D AUTHOR_NAME=%author_name% ^
		-D AUTHOR_EMAIL=%author_email% ^
		-D SITE_TITLE=%site_title% ^
		-D SITE_TAGLINE=%site_tagline% ^
		-D BASE_DOMAIN=%BASE_DOMAIN% ^
		-D BASE_URL=%BASE_URL% ^
		-D DATE_FORMAT=%DATE_FORMAT% ^
		-D FILTER_PAGE=1 ^
		-D FILTER_PER_PAGE=%POST_PER_PAGE% ^
		-l -o %output_dir%\page\1\index.html -t templates\main.tmpl !posts_list!
	)
	
	if !count!==%POST_PER_PAGE% (
		echo index page: !count_p!
		blogc -D AUTHOR_NAME=%author_name% ^
		-D AUTHOR_EMAIL=%author_email% ^
		-D SITE_TITLE=%site_title% ^
		-D SITE_TAGLINE=%site_tagline% ^
		-D BASE_DOMAIN=%BASE_DOMAIN% ^
		-D BASE_URL=%BASE_URL% ^
		-D DATE_FORMAT=%DATE_FORMAT% ^
		-D FILTER_PAGE=!count_p! ^
		-D FILTER_PER_PAGE=%POST_PER_PAGE% ^
		-l -o %output_dir%\page\!count_p!\index.html -t templates\main.tmpl !posts_list!
		set /a count_p += 1
		set count=
	)
)


REM  - Generate other pages --------------------------------------------
set count=1
for %%i in (content\*.txt) do (
	echo other page: !count!
	blogc -D AUTHOR_NAME=%author_name% ^
	-D AUTHOR_EMAIL=%author_email% ^
	-D SITE_TITLE=%site_title% ^
	-D SITE_TAGLINE=%site_tagline% ^
	-D BASE_DOMAIN=%BASE_DOMAIN% ^
	-D BASE_URL=%BASE_URL% ^
	-D DATE_FORMAT=%DATE_FORMAT% ^
	-o %output_dir%\%%~ni.html -t templates\main.tmpl %%i
	set /a count += 1
)


REM  -  Generate atom rss ----------------------------------------------
echo generating atom rss
blogc -D AUTHOR_NAME=%author_name% ^
-D AUTHOR_EMAIL=%author_email% ^
-D SITE_TITLE=%site_title% ^
-D SITE_TAGLINE=%site_tagline% ^
-D BASE_DOMAIN=%BASE_DOMAIN% ^
-D BASE_URL=%BASE_URL% ^
-D DATE_FORMAT=%DATE_FORMAT_ATOM% ^
-D FILTER_PAGE=1 ^
-D FILTER_PER_PAGE=%POST_PER_PAGE_ATOM% ^
-l -o %output_dir%\atom.xml -t templates\atom.tmpl !posts_list!