let g:airline#extensions#tmuxline#enabled = 1
let airline#extensions#tmuxline#snapshot_file = '~/.tmux/tmux-status.conf'

let g:tmuxline_preset = {
      \'a'    : '#S',
      \'b'    : '#W',
      \'c'    : '#H',
      \'win'  : '#I #W',
      \'cwin' : '#I #W',
      \'x'    : '%a',
      \'y'    : '#W %R',
      \'z'    : '#H'}
