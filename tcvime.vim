" vi:set ts=8 sts=2 sw=2 tw=0:
"
" tcvime.vim - tcode.vim等の漢字直接入力keymapでの入力補助機能:
"              交ぜ書き変換、部首合成変換、打鍵ヘルプ表示機能。
"
" Last Change: $Date: 2003/05/19 12:51:42 $
" Maintainer: deton(KIHARA Hideto)@m1.interq.or.jp
" Original Plugin: vime.vim by Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

" Description:
" 使用法:
"   mazegaki.dicとbushu.revは$VIMか'runtimepath'で示されるディレクトリに
"   置いておいてください。
"
"   :TcvimeOnコマンドでマッピングが有効になります。
"   tcvimeの機能は'mapleader'で指定されたキーの後に
"   'q'などのキーを入力することで実行されます。
"   'mapleader'のデフォルトは"\<C-J>"(CTRLキーを押しながらj)です。
"   以降の説明中の<Leader>という文字列はmapleaderを表しています。
"   つまり、mapleaderが"\<C-J>"の場合、<Leader>q は CTRL-Jの後にqを入力する、
"   ということです。
"   また、<Space>はスペースキー、<CR>はエンターキーです。
"
"  Insert Modeでの交ぜ書き変換:
"    <Leader>q で変換対象文字列の始まりをマークします。
"    <Leader><Space> で交ぜ書き変換を行います。
"      <Leader>q でマークした位置から現在のカーソル位置の間にある文字列を
"      読みとしてmazegaki.dicで検索します。
"      候補が一つしかない場合は変換対象文字列を置き換えます。
"      候補が複数ある場合は、コマンド行の上にCANDIDATE: で候補が表示されます。
"      同じ変換対象文字列に対して<Leader><Space>を繰り返し打つと、
"      候補を順に表示していきます。
"      候補のリストの最後まで行くとリストの最初に戻ります。
"    <Leader><CR> でCANDIDATE: として表示されている候補を選択して
"      変換対象文字列を置き換えます。
"
"    例: "<Leader>qあい<Leader><Space>"と打つと、
"        "CANDIDATE: 娃"と表示されます。
"        さらに"<Leader><Space>"を打つと"CANDIDATE: 哀"となります。
"        この状態で"<Leader><CR>"を打つと、"あい"が"哀"に置き換えられます。
"
"  Insert Modeでの交ぜ書き変換(活用する語):
"    基本的には活用しない語の交ぜ書き変換と同じです。
"    "―"をつけて<Leader><Space>で変換するか、活用しない部分まで入力してから、
"    <Leader>o で変換します。
"    <Leader>o は<Leader>q でマークした位置から現在のカーソル位置の間の文字列に
"    "―"を付加した文字列を読みとしてmazegaki.dicから検索します。
"
"    例: "<Leader>qながめ<Leader>o"と打つと、"CANDIDATE: 眺め"と表示されます。
"        "<Leader><CR>"と打つと、"ながめ"が"眺め"に置き換えられます。
"
"  Insert Modeでの部首合成変換:
"    <Leader>b でカーソル位置の直前の2文字の部首合成変換を行います。
"
"    例: "木口<Leader>b"と打つと、"木口"が"杏"に置き換えられます。
"
"  Normal Modeでの交ぜ書き変換:
"    [count]<Leader><Space> カーソル位置以前の[count]文字の交ぜ書き変換を
"      行います。
"    <Leader><CR> でCANDIDATE: として表示されている候補を選択して
"      変換対象文字列を置き換えます。
"
"    例: "あい"と表示されているとき、"い"の上にカーソルを置いて
"        "2<Leader><Space>"と打つと、"CANDIDATE: 娃"と表示されます。
"        さらに"<Leader><Space>"と打つと、"CANDIDATE: 哀"と表示されます。
"        この状態で"<Leader><CR>"を打つと、"あい"が"哀"に置き換えられます。
"
"  Normal Modeでの交ぜ書き変換(活用しない語):
"    [count]<Leader>o カーソル位置以前の[count]文字に"―"を付加した文字列を
"      読みとしてmazegaki.dicから検索します。
"
"    例: "ながめ"と表示されているとき、"め"の上にカーソルを置いて
"        "3<Leader>o"と打つと、"CANDIDATE: 眺め"と表示されます。
"        "<Leader><CR>"と打つと、"ながめ"が"眺め"に置き換えられます。
"
"  Normal Modeでの部首合成変換:
"    <Leader>b カーソル位置以前の2文字の部首合成変換を行います。
"
"    例: "木口"と表示されているとき、"口"の上にカーソルを置いて
"        "<Leader>b"と打つと、"木口"が"杏"に置き換えられます。
"
" 打鍵ヘルプ表示(Normal Mode):
"    <Leader>? でカーソル位置の文字の打鍵を表示します。
"      使用中のkeymapで直接入力できない文字の場合は、
"      部首合成変換辞書を検索して、指定された文字が含まれる行を表示します。
"
"    例: "鍵"という文字の上にカーソルを置いて"<Leader>?"と打つと、
"        "[TcvimeHelp]"というバッファが開いて次のように表示されます
"        (keymapがtutcodeの場合)。
"        ・・・・    ・・・・    鍵
"        ・・・・  3 ・・・・
"        ・・・・    ・・・・
"        ・・1 2     ・・・・
"
" オプション:
"    'tcvime_keyboard'
"       打鍵ヘルプ表示用のキーボード配列を表す文字列。
"       キーの後にスペース、を2回ずつ記述する。
"       例:
"         let tcvime_keyboard = "1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 0 0 \<CR>q q w w e e r r t t y y u u i i o o p p \<CR>a a s s d d f f g g h h j j k k l l ; ; \<CR>z z x x c c v v b b n n m m , , . . / / "
"
"    'mapleader'
"       |mapleader|

" このプラグインを読込みたくない時は.vimrcに次のように書くこと:
"       :let plugin_tcvime_disable = 1

if exists('plugin_tcvime_disable')
  finish
endif

if !exists("tcvime_keyboard")
  let tcvime_keyboard = "1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 0 0 \<CR>q q w w e e r r t t y y u u i i o o p p \<CR>a a s s d d f f g g h h j j k k l l ; ; \<CR>z z x x c c v v b b n n m m , , . . / / "
  " 数字キーの段を表示しない場合は次の文字列を使うようにする(qwerty)
"  let tcvime_keyboard = "q q w w e e r r t t y y u u i i o o p p \<CR>a a s s d d f f g g h h j j k k l l ; ; \<CR>z z x x c c v v b b n n m m , , . . / / "
endif

" Mapping
command! TcvimeOn :call <SID>MappingOn()
command! TcvimeOff :call <SID>MappingOff()
" keymapを設定して、TcvimeOnする
" 引数: keymap名
command! -nargs=1 TcvimeInit :call <SID>TcvimeInit(<f-args>)

"   マッピングを有効化
function! s:MappingOn()
  let set_mapleader = 0
  if !exists('g:mapleader')
    let g:mapleader = "\<C-J>"
    let set_mapleader = 1
  endif
  let s:mapleader = g:mapleader
  inoremap <silent> <Leader><CR> <C-O>:call <SID>InputFix()<CR>
  inoremap <silent> <Leader>q <C-O>:call <SID>InputStart()<CR>
  inoremap <silent> <Leader><Space> <C-O>:call <SID>InputConvert()<CR>
  inoremap <silent> <Leader>o <C-O>:call <SID>InputConvertKatuyo()<CR>
  inoremap <silent> <Leader>b <C-O>:call <SID>InputConvertBushu(1)<CR>
  nnoremap <silent> <Leader><CR> :<C-U>call <SID>FixCandidate()<CR>
  nnoremap <silent> <Leader><Space> :<C-U>call <SID>ConvertCount(v:count)<CR>
  nnoremap <silent> <Leader>o :<C-U>call <SID>ConvertKatuyo(v:count)<CR>
  nnoremap <silent> <Leader>b :<C-U>call <SID>ConvertBushu()<CR>
  nnoremap <silent> <Leader>? :<C-U>call <SID>ShowStrokeHelp()<CR>
  if set_mapleader
    unlet g:mapleader
  endif

  augroup Tcvime
  autocmd!
  execute "autocmd BufReadCmd ".s:helpbufpat." call <SID>Help_BufReadCmd()"
  augroup END

  call s:StatusReset()
endfunction

"   マッピングを無効化
function! s:MappingOff()
  let set_mapleader = 0
  if !exists('g:mapleader')
    let g:mapleader = "\<C-J>"
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
endfunction

" keymapを設定してTcvimeのMappingを有効にする
function! s:TcvimeInit(keymapname)
  if &keymap !=# a:keymapname
    let &keymap = a:keymapname
    call s:MappingOn()
  endif
endfunction


" 設定
let s:candidate_file = globpath($VIM.','.&runtimepath, 'mazegaki.dic')
let s:bushu_file = globpath($VIM.','.&runtimepath, 'bushu.rev')
"echo "candidate_file: ".s:candidate_file
let s:helpbufname = '[TcvimeHelp]'
let s:helpbufpat = '\[TcvimeHelp\]'

"==============================================================================
"				    辞書検索
"

" 辞書データファイルをオープン
function! s:Candidate_FileOpen()
  if filereadable(s:candidate_file) != 1
    return 0
  endif
  if s:SelectWindowByName(s:candidate_file) < 0
    execute 'silent normal! :sv '.s:candidate_file."\<CR>"
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
" 候補が一つしかない場合は1を返す。候補が複数ある場合は0を返す。
function! s:CandidateSearch(keyword)
  let found_num = s:last_found
  let uniq = 0

  " 検索文字列が前回と同じ時は省略
  if s:last_keyword !=# a:keyword
    let s:last_keyword = a:keyword
    if !s:Candidate_FileOpen()
      return 0
    endif

    " 実際の検索
    let v:errmsg = ""
    silent! execute "normal! gg/^" . a:keyword . " \<CR>"
    if v:errmsg != ""
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
    if !uniq
      echo "CANDIDATE: ".str
    endif
  else
    " 候補がみつからなかった時、リセット
    let s:last_candidate = ''
    let s:last_candidate_str = ''
    let s:last_candidate_num = 0
  endif
  let s:last_found = found_num
  return uniq
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
    let &cmdheight = s:save_cmdheight
    unlet s:save_cmdheight
  endif
endfunction

"
" SelectWindowByName(name) [global function]
"   Acitvate selected window by a:name.
"
function! s:SelectWindowByName(name)
  let num = bufwinnr(a:name)
  if num >= 0 && num != winnr()
    execute 'normal! ' . num . "\<C-W>\<C-W>"
  endif
  return num
endfunction

" 部首合成辞書データファイルをオープン
function! s:Bushu_FileOpen()
  if filereadable(s:bushu_file) != 1
    return 0
  endif
  if s:SelectWindowByName(s:bushu_file) < 0
    execute 'silent normal! :sv '.s:bushu_file."\<CR>"
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
  if v:errmsg == ""
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
  if v:errmsg == ""
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
  if v:errmsg == ""
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
  if a:ch !=# '' && a:ch !=# a:char1 && a:ch !=# a:char2
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

    " 引き算
    if ch1a1 !=# '' && ch1a2 !=# '' && ch1a2 ==# ch2alt
      let retchar = ch1a1
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if ch1a1 !=# '' && ch1a2 !=# '' && ch1a1 ==# ch2alt
      let retchar = ch1a2
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 一方が部品による足し算
    if ch1alt !=# '' && ch2a1 !=# ''
      let retchar = s:BushuSearchCompose(ch1alt, ch2a1)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if ch1alt !=# '' && ch2a2 !=# ''
      let retchar = s:BushuSearchCompose(ch1alt, ch2a2)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if ch1a1 !=# '' && ch2alt !=# ''
      let retchar = s:BushuSearchCompose(ch1a1, ch2alt)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if ch1a2 !=# '' && ch2alt !=# ''
      let retchar = s:BushuSearchCompose(ch1a2, ch2alt)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 両方が部品による足し算
    if ch1a1 !=# '' && ch2a1 !=# ''
      let retchar = s:BushuSearchCompose(ch1a1, ch2a1)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if ch1a1 !=# '' && ch2a2 !=# ''
      let retchar = s:BushuSearchCompose(ch1a1, ch2a2)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if ch1a2 !=# '' && ch2a1 !=# ''
      let retchar = s:BushuSearchCompose(ch1a2, ch2a1)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if ch1a2 !=# '' && ch2a2 !=# ''
      let retchar = s:BushuSearchCompose(ch1a2, ch2a2)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 部品による引き算
    if ch1a2 !=# '' && ch2a1 !=# '' && ch1a2 ==# ch2a1
      let retchar = ch1a1
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if ch1a2 !=# '' && ch2a2 !=# '' && ch1a2 ==# ch2a2
      let retchar = ch1a1
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if ch1a1 !=# '' && ch2a1 !=# '' && ch1a1 ==# ch2a1
      let retchar = ch1a2
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if ch1a1 !=# '' && ch2a2 !=# '' && ch1a1 ==# ch2a2
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

"==============================================================================
"				    入力制御
"

function! s:InputConvert()
  let col = col("'^")
  let s:is_katuyo = 0
  let status = s:StatusGet()
  let uniq = 0
  let len = strlen(status)
  if len > 0
    let uniq = s:CandidateSearch(status)
  else
    let s:last_keyword = ''
    call s:StatusReset()
  endif
  execute "normal! " . col . "|"
  if uniq
    call s:InputFix()
  endif
endfunction

" 活用のある単語の変換を行う。
" 変換対象文字列の末尾に「―」を追加して交ぜ書き辞書を検索する。
function! s:InputConvertKatuyo()
  let col = col("'^")
  let status = s:StatusGet()
  let uniq = 0
  let len = strlen(status)
  if len > 0
    let s:is_katuyo = 1
    let uniq = s:CandidateSearch(status . '―')
  else
    let s:last_keyword = ''
    call s:StatusReset()
  endif
  execute "normal! " . col . "|"
  if uniq
    call s:InputFix()
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

function! s:InputFix()
  let str = s:StatusGet()
  if s:IsCandidateOK(str)
    let len = strlen(str)
    call s:CandidateSelect(len)
    execute "normal! " . s:status_column . "|"
  endif
  call s:StatusReset()
endfunction

function! s:InputStart()
  let s:save_cmdheight = &cmdheight
  if &cmdheight < 2
    let &cmdheight = 2
  endif
  call s:StatusSet()
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
    endif
    let &ve = save_ve
  endif
endfunction

" 今の位置以前の2文字を部首合成変換する
function! s:ConvertBushu()
  execute "normal! a\<ESC>"
  call s:InputConvertBushu(0)
endfunction

" 以前のConvertCount(), ConvertKatuyo()に渡されたcount引数の値。
" countが0で実行された場合に以前のcount値を使うようにするため。
let s:last_count = 0

" 今の位置以前のcount文字を変換する
function! s:ConvertCount(count)
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
    let s:save_cmdheight = &cmdheight
    if &cmdheight < 2
      let &cmdheight = 2
    endif
    let uniq = s:CandidateSearch(status)
    if uniq
      call s:FixCandidate()
    endif
  else
    let s:last_keyword = ''
    let s:last_count = 0
    call s:StatusReset()
  endif
endfunction

" 今の位置以前のcount文字を活用のある語として変換する
function! s:ConvertKatuyo(count)
  let cnt = a:count
  if cnt == 0
    let cnt = s:last_count
    if cnt == 0
      let cnt = 1
    endif
  endif
  let s:last_count = cnt

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
    let s:save_cmdheight = &cmdheight
    if &cmdheight < 2
      let &cmdheight = 2
    endif
    let s:is_katuyo = 1
    let uniq = s:CandidateSearch(status . '―')
    if uniq
      call s:FixCandidate()
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
  let str = s:StatusGet()
  if s:IsCandidateOK(str)
    let len = strlen(str)
    call s:CandidateSelect(len)
    execute "normal! " . (s:status_column - 1) . "|"
  endif
  let s:last_count = 0
  call s:StatusReset()
endfunction

"==============================================================================
" ヘルプ表示

" 空のヘルプ用バッファを作る
function! s:Help_BufReadCmd()
  set ft=
  set buftype=nofile
  set bufhidden=delete
  set noswapfile
endfunction

" ヘルプ用バッファを開く
function! s:OpenHelpBuffer()
  if s:SelectWindowByName(s:helpbufname) < 0
    execute "silent normal! :sp " . s:helpbufname . "\<CR>"
  endif
  execute "normal! :%d\<CR>4\<C-W>\<C-_>"
endfunction

" カーソル位置の文字の打鍵を表示する
function! s:ShowStrokeHelp()
  let col1 = col(".")
  execute "normal! a\<ESC>"
  let col2 = col("'^")
  let ch = strpart(getline("."), col1 - 1, col2 - col1)
  call s:ShowHelp(ch)
endfunction

" 指定された文字を入力するための打鍵を表示する
function! s:ShowHelp(ch)
  if strlen(a:ch) == 0 || &keymap == ""
    return
  endif
  let keyseq = s:SearchKeymap(a:ch)
  if strlen(keyseq) > 0
    call s:ShowHelpSequence(a:ch, keyseq)
  else
    call s:ShowHelpBushuDic(a:ch)
  endif
endfunction

" 指定された文字とその打鍵を表にして表示する
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
  if v:errmsg == ""
    let lines = getline('.')
    let save_wrapscan = &wrapscan
    let &wrapscan = 0
    while v:errmsg == ""
      let v:errmsg = ""
      silent! execute "normal! n"
      if v:errmsg == ""
	let lines = lines . "\<CR>" . getline('.')
      endif
    endwhile
    let &wrapscan = save_wrapscan
  endif
  quit!
  return lines
endfunction

" 指定された文字を入力するための打鍵をkeymapファイルから検索する
function! s:SearchKeymap(ch)
  let kmfile = globpath(&rtp, "keymap/" . &keymap . "_" . &encoding . ".vim")
  if filereadable(kmfile) != 1
    let kmfile = globpath(&rtp, "keymap/" . &keymap . ".vim")
    if filereadable(kmfile) != 1
      return ""
    endif
  endif
  execute "silent normal! :sv " . kmfile . "\<CR>"
  let v:errmsg = ""
  execute "normal! /loadkeymap/\<CR>"
  silent! execute 'normal! /^[^"].*[^ 	]\+[ 	]\+' . a:ch . "/\<CR>"
  if v:errmsg == ""
    let keyseq = substitute(getline('.'), '[ 	]\+.*$', '', '')
  else
    let keyseq = ""
  endif
  quit!
  return keyseq
endfunction

"==============================================================================
"			     未確定文字管理用関数群
"

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
  echo "New conversion (line=".s:status_line." column=".s:status_column.")"
endfunction

call s:StatusReset()
