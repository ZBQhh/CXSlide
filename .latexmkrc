$pdf_mode = 5;
$xelatex  = 'xelatex -file-line-error -halt-on-error '
          . '-interaction=nonstopmode -synctex=1 %O %S';
$max_repeat = 5;
$bibtex_use = 0;
$out_dir    = 'build';
$aux_dir    = 'build';
$clean_ext  = 'nav snm vrb synctex.gz run.xml';
push @generated_exts, 'nav', 'snm', 'vrb';
