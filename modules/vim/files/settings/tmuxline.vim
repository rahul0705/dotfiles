let g:airline#extensions#tmuxline#enabled = 1
let airline#extensions#tmuxline#snapshot_file = '~/.tmux/tmux-status.conf'

let g:tmuxline_preset = {
      \'a'    : '#S',
      \'b'    : ['#W', '#P'],
      \'c'    : '#{prefix_highlight}',
      \'win'  : ['#I', '#W'],
      \'cwin' : ['#F', '#W'],
      \'x'    : '%a',
      \'y'    : '%R',
      \'z'    : '#H'}
