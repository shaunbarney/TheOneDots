fun! TrimWhiteSpace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

augroup BARNEY_FUNCS
    autocmd!
    autocmd BufWritePre * :call TrimWhiteSpace()
augroup END
