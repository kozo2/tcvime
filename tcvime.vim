" vi:set ts=8 sts=2 sw=2 tw=0:
"
" tcvime.vim - tcode,tutcode等の漢字直接入力keymapでの入力補助機能:
"              交ぜ書き変換、部首合成変換、文字ヘルプ表表示機能。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Revision: $Id: tcvime.vim,v 1.26 2003/05/25 04:42:28 deton Exp $
" Original Plugin: vime.vim by Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

" Description:
" コマンド:
"   :TcvimeOn         キーマッピングを有効化する
"   :TcvimeOff        キーマッピングを無効化する
"   :TcvimeHelp       指定した文字のヘルプ表を表示する
"   :TcvimeSetKeymap  keymapをsetする
"
" imap:
"   <Leader>q       交ぜ書き変換: 読みを開始
"   <Leader><Space> 交ぜ書き変換: 変換実行
"   <Leader><CR>    交ぜ書き変換: 候補確定
"   <Leader>o       交ぜ書き変換: 活用する語の変換実行
"   <Leader>b       部首合成変換: 直前の2文字の部首合成変換実行
"
" nmap:
"   [count]<Leader><Space>  交ぜ書き変換: カーソル位置以前の[count]文字の変換
"   <Leader><CR>            交ぜ書き変換: 候補確定
"   [count]<Leader>o        交ぜ書き変換: [count]文字の活用する語の変換
"   <Leader>b               部首合成変換: カーソル位置以前の2文字の部首合成変換
"   <Leader>?               打鍵ヘルプ表示: カーソル位置の文字のヘルプ表を表示
"
" オプション:
"    'tcvime_keyboard'
"       文字ヘルプ表用のキーボード配列を表す文字列。
"       キーの後にスペース、を2回ずつ記述する。
"       例:
"         let tcvime_keyboard = "1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 0 0 \<CR>q q w w e e r r t t y y u u i i o o p p \<CR>a a s s d d f f g g h h j j k k l l ; ; \<CR>z z x x c c v v b b n n m m , , . . / / "
"
"    'mapleader'
"       キーマッピングのプレフィックス。|mapleader|を参照。省略値: CTRL-K
"       CTRL-Kを指定する場合の例:
"         let mapleader = "\<C-K>"
"
"    'plugin_tcvime_disable'
"       このプラグインを読み込みたくない場合に次のように設定する。
"         let plugin_tcvime_disable = 1

if exists('plugin_tcvime_disable')
  finish
endif

if !exists("tcvime_keyboard")
  let tcvime_keyboard = "1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 0 0 \<CR>q q w w e e r r t t y y u u i i o o p p \<CR>a a s s d d f f g g h h j j k k l l ; ; \<CR>z z x x c c v v b b n n m m , , . . / / "
  " 数字キーの段を表示しない場合は次の文字列を使うようにする(qwerty)
"  let tcvime_keyboard = "q q w w e e r r t t y y u u i i o o p p \<CR>a a s s d d f f g g h h j j k k l l ; ; \<CR>z z x x c c v v b b n n m m , , . . / / "
endif

" 設定
let s:candidate_file = globpath($VIM.','.&runtimepath, 'mazegaki.dic')
let s:bushu_file = globpath($VIM.','.&runtimepath, 'bushu.rev')
let s:helpbufname = '\[TcvimeHelp\]'
" 辞書ファイルが:ls等で表示されるようにするかどうか。0:表示されない,1:表示する
let s:buflisted = 0

" Mapping
command! TcvimeOn call <SID>MappingOn()
command! TcvimeOff call <SID>MappingOff()
" keymapを設定する
" 引数: keymap名
command! -nargs=1 TcvimeSetKeymap call <SID>SetKeymap(<args>)
" 指定された文字のヘルプ表を表示する
" 引数: 対象の文字
command! -nargs=1 TcvimeHelp call <SID>ShowHelp(<args>)

" keymapを設定する
function! s:SetKeymap(keymapname)
  if &keymap !=# a:keymapname
    let &keymap = a:keymapname
  endif
endfunction

"   マッピングを有効化
function! s:MappingOn()
  let set_mapleader = 0
  if !exists('g:mapleader')
    let g:mapleader = "\<C-K>"
    let set_mapleader = 1
  endif
  let s:mapleader = g:mapleader
  inoremap <silent> <Leader><CR> <C-O>:call <SID>InputFix(1)<CR>
  inoremap <silent> <Leader>q <C-O>:call <SID>InputStart()<CR>
  inoremap <silent> <Leader><Space> <C-O>:call <SID>InputConvert(0)<CR>
  inoremap <silent> <Leader>o <C-O>:call <SID>InputConvert(1)<CR>
  inoremap <silent> <Leader>b <C-O>:call <SID>InputConvertBushu(1)<CR>
  nnoremap <silent> <Leader><CR> :<C-U>call <SID>FixCandidate()<CR>
  nnoremap <silent> <Leader><Space> :<C-U>call <SID>ConvertCount(v:count, 0)<CR>
  nnoremap <silent> <Leader>o :<C-U>call <SID>ConvertCount(v:count, 1)<CR>
  nnoremap <silent> <Leader>b :<C-U>call <SID>ConvertBushu()<CR>
  nnoremap <silent> <Leader>? :<C-U>call <SID>ShowStrokeHelp()<CR>
  if set_mapleader
    unlet g:mapleader
  endif

  augroup Tcvime
  autocmd!
  execute "autocmd BufReadCmd ".s:helpbufname." call <SID>Help_BufReadCmd()"
  augroup END

  if !exists('s:save_cmdheight')
    let s:save_cmdheight = &cmdheight
  endif
endfunction

"   マッピングを無効化
function! s:MappingOff()
  let set_mapleader = 0
  if !exists('g:mapleader')
    let g:mapleader = "\<C-K>"
    let set_mapleader = 1
  else
    let save_mapleader = g:mapleader
  endif
  let g:mapleader = s:mapleader
  silent! iunmap <Leader><CR>
  silent! iunmap <Leader>q
  silent! iunmap <Leader><Space>
  silent! iunmap <Leader>o
  silent! iunmap <Leader>b
  silent! nunmap <Leader><CR>
  silent! nunmap <Leader><Space>
  silent! nunmap <Leader>o
  silent! nunmap <Leader>b
  silent! nunmap <Leader>?
  if set_mapleader
    unlet g:mapleader
  else
    let g:mapleader = save_mapleader
  endif

  augroup Tcvime
  autocmd!
  augroup END
  unlet s:save_cmdheight
endfunction

TcvimeOn

"==============================================================================
"				    入力制御

" 読みの入力を開始
function! s:InputStart()
  call s:SetCmdheight()
  call s:StatusSet()
endfunction

" Insert modeで交ぜ書き変換を行う。
" 活用する語の変換の場合は、
" 変換対象文字列の末尾に「―」を追加して交ぜ書き辞書を検索する。
" @param katuyo 活用する語の変換かどうか。0:活用しない, 1:活用する
function! s:InputConvert(katuyo)
  let col = col("'^")
  let s:is_katuyo = 0
  let status = s:StatusGet()
  let len = strlen(status)
  if len > 0
    let s:is_katuyo = a:katuyo
    if s:is_katuyo
      let status = status . '―'
    endif
    let found = s:CandidateSearch(status)
  else
    let s:last_keyword = ''
    call s:InputStart()
  endif
  execute "normal! " . col . "|"
  if exists('found')
    if found == 2
      echo 'CANDIDATE: ' . s:last_candidate
    elseif found == 1
      call s:InputFix(1)
    elseif found == 0
      echo '交ぜ書き辞書中には見つかりません: <' . status . '>'
    elseif found == -1
      echo '交ぜ書き変換辞書ファイルのオープンに失敗しました: ' . s:candidate_file
    endif
  endif
endfunction

" 確定しようとしている候補が問題ないかどうかチェック
function! s:IsCandidateOK(str)
  if strlen(a:str) > 0 && strlen(s:last_candidate) > 0
    if s:is_katuyo && s:last_keyword ==# (a:str . '―') || s:last_keyword ==# a:str
      return 1
    endif
  endif
  return 0
endfunction

" 候補を確定する
function! s:InputFix(is_insert_mode)
  let str = s:StatusGet()
  if s:IsCandidateOK(str)
    let len = strlen(str)
    call s:CandidateSelect(len)
    let col = s:status_column
    if !a:is_insert_mode
      let col = col - 1
    endif
    execute "normal! " . col . "|"
  endif
  call s:StatusReset()
  let &cmdheight = s:save_cmdheight
endfunction

" &cmdheightが2より小さかったら2に設定する。CANDIDATE:表示のため。
function! s:SetCmdheight()
  if &cmdheight < 2
    let &cmdheight = 2
  endif
endfunction

" 直前の2文字の部首合成変換を行う
function! s:InputConvertBushu(is_insert_mode)
  let col3 = col("'^")
  if col3 > 3
    let save_ve = &ve
    let &ve = 'all'
    execute "normal! " . col3 . "|h"
    let col2 = col(".")
    execute "normal! h"
    let col1 = col(".")
    let str = getline('.')
    let char1 = strpart(str, col1 - 1, col2 - col1)
    let char2 = strpart(str, col2 - 1, col3 - col2)
    let retchar = s:BushuSearch(char1, char2)
    let len = strlen(retchar)
    if len > 0
      call s:BushuReplace(line("."), col1, col3, retchar)
      if a:is_insert_mode
	execute "normal! " . col2 . "|"
      else
	execute "normal! " . col1 . "|"
      endif
    else
      if a:is_insert_mode
	execute "normal! " . col3 . "|"
      else
	execute "normal! " . col2 . "|"
      endif
      echo '部首合成変換ができませんでした: <' . char1 . '>, <' . char2 . '>'
    endif
    let &ve = save_ve
  endif
endfunction

" 以前のConvertCount()に渡されたcount引数の値。
" countが0で実行された場合に以前のcount値を使うようにするため。
let s:last_count = 0

" 今の位置以前のcount文字を変換する
" @param count 変換する文字列の長さ
" @param katuyo 活用する語の変換かどうか。0:活用しない, 1:活用する
function! s:ConvertCount(count, katuyo)
  let cnt = a:count
  if cnt == 0
    let cnt = s:last_count
    if cnt == 0
      let cnt = 1
    endif
  endif
  let s:last_count = cnt

  let s:is_katuyo = 0
  let s:status_line = line(".")
  let save_col = col(".")
  execute "normal! a\<ESC>"
  let cnt = cnt - 1
  if cnt > 0
    execute "normal! " . cnt . "h"
  endif
  let s:status_column = col(".")
  execute "normal! " . save_col . "|"

  let status = s:StatusGet()
  let len = strlen(status)
  if len > 0
    "call s:SetCmdheight()
    let s:is_katuyo = a:katuyo
    if s:is_katuyo
      let status = status . '―'
    endif
    let found = s:CandidateSearch(status)
    if found == 2
      echo 'CANDIDATE: ' . s:last_candidate
    elseif found == 1
      call s:FixCandidate()
    elseif found == 0
      echo '交ぜ書き辞書中には見つかりません: <' . status . '>'
    elseif found == -1
      echo '交ぜ書き変換辞書ファイルのオープンに失敗しました: ' . s:candidate_file
    endif
  else
    let s:last_keyword = ''
    let s:last_count = 0
    call s:StatusReset()
  endif
endfunction

" ConvertCount()で変換を開始した候補を確定する
function! s:FixCandidate()
  execute "normal! a\<ESC>"
  call s:InputFix(0)
  let s:last_count = 0
endfunction

" 今の位置以前の2文字を部首合成変換する
function! s:ConvertBushu()
  execute "normal! a\<ESC>"
  call s:InputConvertBushu(0)
endfunction

"==============================================================================
"			     未確定文字管理用関数群

"   未確定文字列が存在するかチェックする
function! s:StatusIsEnable()
  if s:status_line != line('.') || s:status_column <= 0 || s:status_column > col('.')
    return 0
  endif
  return 1
endfunction

"   未確定文字列を開始する
function! s:StatusSet()
  let s:status_line = line("'^")
  let s:status_column = col("'^")
  call s:StatusEcho()
endfunction

"   未確定文字列をリセットする
function! s:StatusReset()
  let s:status_line = 0
  let s:status_column = 0
endfunction

"   未確定文字列を「状態」として取得する
function! s:StatusGet()
  if !s:StatusIsEnable()
    return ''
  endif

  " 必要なパラメータを収集
  let stpos = s:status_column - 1
  let ccl = col("'^")
  let len = ccl - s:status_column
  let str = getline('.')

  return strpart(str, stpos, len)
endfunction

"   未確定文字列の開始位置と終了位置を表示(デバッグ用)
function! s:StatusEcho(...)
  echo '読み入力開始;<Leader><Space>:変換,<Leader>o:活用する語の変換,<Leader><CR>:確定'
  "echo "New conversion (line=".s:status_line." column=".s:status_column.")"
endfunction

" 状態リセット
call s:StatusReset()

"==============================================================================
" ヘルプ表示

" 空のヘルプ用バッファを作る
function! s:Help_BufReadCmd()
endfunction

" ヘルプ用バッファを開く
function! s:OpenHelpBuffer()
  if s:SelectWindowByName(s:helpbufname) < 0
    execute "silent normal! :sp " . s:helpbufname . "\<CR>"
    set buftype=nofile
    set bufhidden=delete
    set noswapfile
    set winfixheight
    if !s:buflisted
      set nobuflisted
    endif
  endif
  execute "normal! :%d\<CR>4\<C-W>\<C-_>"
endfunction

" カーソル位置の文字のヘルプ表を表示する
function! s:ShowStrokeHelp()
  let col1 = col(".")
  execute "normal! a\<ESC>"
  let col2 = col("'^")
  let ch = strpart(getline("."), col1 - 1, col2 - col1)
  call s:ShowHelp(ch)
endfunction

" 指定された文字のヘルプ表を表示する
function! s:ShowHelp(ch)
  if strlen(a:ch) == 0
    echo '文字ヘルプ表表示に指定された文字が空です。無視します'
    return
  endif
  if strlen(&keymap) == 0
    echo 'keymapオプションが設定されていないので、文字ヘルプ表表示ができません'
    return
  endif
  let keyseq = s:SearchKeymap(a:ch)
  if strlen(keyseq) > 0
    call s:ShowHelpSequence(a:ch, keyseq)
  else
    call s:ShowHelpBushuDic(a:ch)
  endif
endfunction

" 指定された文字とそのストロークを表にして表示する
function! s:ShowHelpSequence(ch, keyseq)
  call s:OpenHelpBuffer()
  execute "normal! ggO" . g:tcvime_keyboard . "\<ESC>"
  let keyseq = a:keyseq
  let i = 0
  while strlen(keyseq) > 0
    let i = i + 1
    let key = strpart(keyseq, 0, 1)
    let keyseq = strpart(keyseq, 1)
    execute "normal! :%s@\\V" . key . " @" . i . "@\<CR>"
  endwhile
  execute "normal! :%s@^\\(....................\\). . @\\1@e\<CR>"
  execute "normal! :%s@^\\(................\\). . @\\1@e\<CR>"
  execute "normal! :%s@\\(.\\)\\(.\\)@\\1\\2@ge\<CR>"
  execute "normal! :%s@\\(.\\). @\\1@ge\<CR>"
  execute "normal! :%s@. . @・@g\<CR>"
  execute "normal! :%s@@ @ge\<CR>"
  execute "normal! 1GA    " . a:ch . "\<ESC>"
  execute "normal! \<C-W>p"
endfunction

" 部首合成辞書から、指定された文字を含む行を検索して表示する
function! s:ShowHelpBushuDic(ch)
  let lines = s:SearchBushuDic(a:ch)
  if strlen(lines) > 0
    call s:OpenHelpBuffer()
    execute "normal! a" . lines . "\<ESC>1G"
    execute "normal! \<C-W>p"
  else
    redraw
    echo '文字ヘルプで表示できる情報がありません: <' . a:ch . '>'
  endif
endfunction

" 部首合成辞書から、指定された文字を含む行を検索する
function! s:SearchBushuDic(ch)
  if !s:Bushu_FileOpen()
    return ""
  endif
  let lines = ""
  let v:errmsg = ""
  silent! execute "normal! gg/" . a:ch . "\<CR>"
  if strlen(v:errmsg) == 0
    let lines = getline('.')
    let save_wrapscan = &wrapscan
    let &wrapscan = 0
    while strlen(v:errmsg) == 0
      let v:errmsg = ""
      silent! execute "normal! n"
      if strlen(v:errmsg) == 0
	let lines = lines . "\<CR>" . getline('.')
      endif
    endwhile
    let &wrapscan = save_wrapscan
  endif
  quit!
  return lines
endfunction

" 指定された文字を入力するためのストロークをkeymapファイルから検索する
function! s:SearchKeymap(ch)
  let kmfile = globpath(&rtp, "keymap/" . &keymap . "_" . &encoding . ".vim")
  if filereadable(kmfile) != 1
    let kmfile = globpath(&rtp, "keymap/" . &keymap . ".vim")
    if filereadable(kmfile) != 1
      return ""
    endif
  endif
  execute "silent normal! :sv " . kmfile . "\<CR>"
  if !s:buflisted
    set nobuflisted
  endif
  let v:errmsg = ""
  execute "normal! /loadkeymap/\<CR>"
  silent! execute 'normal! /^[^"].*[^ 	]\+[ 	]\+' . a:ch . "/\<CR>"
  if strlen(v:errmsg) == 0
    let keyseq = substitute(getline('.'), '[ 	]\+.*$', '', '')
  else
    let keyseq = ""
  endif
  quit!
  return keyseq
endfunction

"==============================================================================
"				    辞書検索

" SelectWindowByName(name)
"   Acitvate selected window by a:name.
function! s:SelectWindowByName(name)
  let num = bufwinnr(a:name)
  if num >= 0 && num != winnr()
    execute 'normal! ' . num . "\<C-W>\<C-W>"
  endif
  return num
endfunction

" 交ぜ書き変換辞書データファイルをオープン
function! s:Candidate_FileOpen()
  if filereadable(s:candidate_file) != 1
    return 0
  endif
  if s:SelectWindowByName(s:candidate_file) < 0
    execute 'silent normal! :sv '.s:candidate_file."\<CR>"
    if !s:buflisted
      set nobuflisted
    endif
  endif
  return 1
endfunction

" 検索に使用する状態変数
let s:last_keyword = ''
let s:last_found = 0
let s:last_candidate = ''
let s:last_candidate_str = ''
let s:last_candidate_num = 0
let s:is_katuyo = 0

" 辞書から未確定文字列を検索
" @return -1:辞書が開けない場合, 0:文字列が見つからない場合,
"   1:候補が1つだけ見つかった場合, 2:候補が2つ以上見つかった場合
function! s:CandidateSearch(keyword)
  let found_num = s:last_found
  let uniq = 0
  let ret = 0

  " 検索文字列が前回と同じ時は省略
  if s:last_keyword !=# a:keyword
    let s:last_keyword = a:keyword
    if !s:Candidate_FileOpen()
      return -1
    endif

    " 実際の検索
    let v:errmsg = ""
    silent! execute "normal! gg/^" . a:keyword . " \<CR>"
    if strlen(v:errmsg) > 0
      let found_num = 0
    else
      let s:last_candidate = ''
      let s:last_candidate_str = substitute(getline('.'), '^' . a:keyword . ' ', '', '')
      let s:last_candidate_num = 1
      let found_num = line('.')
      if s:last_candidate_str =~# '^/[^/]\+/$'
	let uniq = 1
      endif
    endif
    quit!
  else
    " 次の変換候補を探し出すため
    if s:last_candidate_num > 0 && s:last_candidate != ''
      let s:last_candidate_num = s:last_candidate_num + strlen(s:last_candidate) + 1
    endif
    " 前回変換した文字列を再度変換する場合、候補数をチェックし直す
    if s:last_candidate_num == 1 && s:last_candidate == ''
      if s:last_candidate_str =~# '^/[^/]\+/$'
	let uniq = 1
      endif
    endif
  endif

  if found_num > 0
    " 候補がみつかっているならば、順番に表示する
    let str = ''
    while strlen(str) < 1
      let str = matchstr(s:last_candidate_str, '[^/]\+', s:last_candidate_num)
      if strlen(str) < 1
	let s:last_candidate_num = 1
      endif
    endwhile
    let s:last_candidate = str
    if uniq
      let ret = 1
    else
      let ret = 2
    endif
  else
    " 候補がみつからなかった時、リセット
    let s:last_candidate = ''
    let s:last_candidate_str = ''
    let s:last_candidate_num = 0
    let ret = 0
  endif
  let s:last_found = found_num
  return ret
endfunction

" 候補をバッファに挿入
function! s:CandidateSelect(len)
  if strlen(s:last_candidate) > 0
    let str = getline(s:status_line)
    let str = strpart(str, 0, s:status_column - 1).s:last_candidate.strpart(str, s:status_column - 1 + a:len)
    call setline(s:status_line, str)
    let s:status_column = s:status_column + strlen(s:last_candidate)
    let s:last_candidate = ''
    let s:last_candidate_num = 1
  endif
endfunction

" 部首合成辞書データファイルをオープン
function! s:Bushu_FileOpen()
  if filereadable(s:bushu_file) != 1
    return 0
  endif
  if s:SelectWindowByName(s:bushu_file) < 0
    execute 'silent normal! :sv '.s:bushu_file."\<CR>"
    if !s:buflisted
      set nobuflisted
    endif
  endif
  return 1
endfunction

" 等価文字を検索して返す。等価文字がない場合はもとの文字そのものを返す
function! s:BushuAlternative(ch)
  if !s:Bushu_FileOpen()
    return a:ch
  endif
  let v:errmsg = ""
  silent! execute "normal! gg/^." . a:ch . "$\<CR>"
  if strlen(v:errmsg) == 0
    execute "normal! l"
    let retchar = strpart(getline('.'), 0, col('.') - 1)
  else
    let retchar = a:ch
  endif
  quit!
  return retchar
endfunction

" char1とchar2をこの順番で合成してできる文字を検索して返す。
" 見つからない場合は''を返す
function! s:BushuSearchCompose(char1, char2)
  if !s:Bushu_FileOpen()
    return ''
  endif
  let v:errmsg = ""
  silent! execute "normal! gg/^." . a:char1 . a:char2 . "\<CR>"
  if strlen(v:errmsg) == 0
    execute "normal! l"
    let retchar = strpart(getline('.'), 0, col('.') - 1)
  else
    let retchar = ''
  endif
  quit!
  return retchar
endfunction

" 指定された文字を2つの部首に分解する。
" 分解した部首をs:decomp1, s:decomp2にセットする。
" @return 1: 分解に成功した場合、0: 分解できなかった場合
function! s:BushuDecompose(ch)
  if !s:Bushu_FileOpen()
    return 0
  endif
  let v:errmsg = ""
  silent! execute "normal! gg/^" . a:ch . "..\<CR>"
  if strlen(v:errmsg) == 0
    let save_ve = &ve
    let &ve = 'all'
    execute "normal! l"
    let pos1 = col('.') - 1
    execute "normal! l"
    let pos2 = col('.') - 1
    execute "normal! l"
    let pos3 = col('.') - 1
    let &ve = save_ve
    let str = getline('.')
    let s:decomp1 = strpart(str, pos1, pos2 - pos1)
    let s:decomp2 = strpart(str, pos2, pos3 - pos2)
    let ret = 1
  else
    let ret = 0
  endif
  quit!
  return ret
endfunction

" 合成後の文字が空でなく、元の文字でもないことを確認
" @param ch 合成後の文字
" @param char1 元の文字
" @param char2 元の文字
" @return 1: chが空でもchar1でもchar2でもない場合。0: それ以外の場合
function! s:BushuCharOK(ch, char1, char2)
  if strlen(a:ch) > 0 && a:ch !=# a:char1 && a:ch !=# a:char2
    return 1
  else
    return 0
  endif
endfunction

" 部首合成変換辞書を検索
function! s:BushuSearch(char1, char2)
  let char1 = a:char1
  let char2 = a:char2
  let i = 0
  while i < 2
    " そのまま合成できる?
    let retchar = s:BushuSearchCompose(char1, char2)
    if s:BushuCharOK(retchar, char1, char2)
      return retchar
    endif

    " 等価文字どうしで合成できる?
    if !exists("ch1alt")
      let ch1alt = s:BushuAlternative(char1)
    endif
    if !exists("ch2alt")
      let ch2alt = s:BushuAlternative(char2)
    endif
    let retchar = s:BushuSearchCompose(ch1alt, ch2alt)
    if s:BushuCharOK(retchar, char1, char2)
      return retchar
    endif

    " 等価文字を部首に分解
    if !exists("ch1a1")
      if s:BushuDecompose(ch1alt) == 1
	let ch1a1 = s:decomp1
	let ch1a2 = s:decomp2
	unlet s:decomp1
	unlet s:decomp2
      else
	let ch1a1 = ''
	let ch1a2 = ''
      endif
    endif
    if !exists("ch2a1")
      if s:BushuDecompose(ch2alt) == 1
	let ch2a1 = s:decomp1
	let ch2a2 = s:decomp2
	unlet s:decomp1
	unlet s:decomp2
      else
	let ch2a1 = ''
	let ch2a2 = ''
      endif
    endif

    let lench1a1 = strlen(ch1a1)
    let lench1a2 = strlen(ch1a2)
    let lench2a1 = strlen(ch2a1)
    let lench2a2 = strlen(ch2a2)
    let lench1alt = strlen(ch1alt)
    let lench2alt = strlen(ch2alt)

    " 引き算
    if lench1a1 > 0 && lench1a2 > 0 && ch1a2 ==# ch2alt
      let retchar = ch1a1
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a1 > 0 && lench1a2 > 0 && ch1a1 ==# ch2alt
      let retchar = ch1a2
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 一方が部品による足し算
    if lench1alt > 0 && lench2a1 > 0
      let retchar = s:BushuSearchCompose(ch1alt, ch2a1)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1alt > 0 && lench2a2 > 0
      let retchar = s:BushuSearchCompose(ch1alt, ch2a2)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a1 > 0 && lench2alt > 0
      let retchar = s:BushuSearchCompose(ch1a1, ch2alt)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a2 > 0 && lench2alt > 0
      let retchar = s:BushuSearchCompose(ch1a2, ch2alt)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 両方が部品による足し算
    if lench1a1 > 0 && lench2a1 > 0
      let retchar = s:BushuSearchCompose(ch1a1, ch2a1)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a1 > 0 && lench2a2 > 0
      let retchar = s:BushuSearchCompose(ch1a1, ch2a2)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a2 > 0 && lench2a1 > 0
      let retchar = s:BushuSearchCompose(ch1a2, ch2a1)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a2 > 0 && lench2a2 > 0
      let retchar = s:BushuSearchCompose(ch1a2, ch2a2)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 部品による引き算
    if lench1a2 > 0 && lench2a1 > 0 && ch1a2 ==# ch2a1
      let retchar = ch1a1
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a2 > 0 && lench2a2 > 0 && ch1a2 ==# ch2a2
      let retchar = ch1a1
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a1 > 0 && lench2a1 > 0 && ch1a1 ==# ch2a1
      let retchar = ch1a2
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a1 > 0 && lench2a2 > 0 && ch1a1 ==# ch2a2
      let retchar = ch1a2
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 文字の順を逆にしてやってみる
    let t = char1  | let char1  = char2  | let char2 = t
    let t = ch1alt | let ch1alt = ch2alt | let ch2alt = t
    let t = ch1a1  | let ch1a1  = ch2a1  | let ch2a1 = t
    let t = ch1a2  | let ch1a2  = ch2a2  | let ch2a2 = t
    let i = i + 1
  endwhile

  " 合成できなかった
  return ''
endfunction

" 部首合成した文字をバッファに挿入
function! s:BushuReplace(linenum, stcol, endcol, ch)
  let str = getline(a:linenum)
  let str = strpart(str, 0, a:stcol - 1) . a:ch . strpart(str, a:endcol - 1)
  call setline(a:linenum, str)
endfunction
