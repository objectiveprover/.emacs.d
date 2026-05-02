;;; -*- lexical-binding: t; -*-

;; ================================================================================
;; Colors

;; --------------------------------------------------
;; Flexoki (https://github.com/kepano/flexoki)

;; Base
(setq flexoki-base-paper "#FFFCF0"
      flexoki-base-50 "#F2F0E5"
      flexoki-base-100 "#E6E4D9"
      flexoki-base-150 "#DAD8CE"
      flexoki-base-200 "#CECDC3"
      flexoki-base-300 "#B7B5A9"
      flexoki-base-400 "#9F9D96"
      flexoki-base-500 "#878580"
      flexoki-base-600 "#6F6E69"
      flexoki-base-700 "#575653"
      flexoki-base-800 "#403E3C"
      flexoki-base-850 "#343331"
      flexoki-base-900 "#282726"
      flexoki-base-950 "#1C1B1A"
      flexoki-black "#100F0F")

;; Red
(setq flexoki-red-50 "#FFE1D5"
      flexoki-red-100 "#FFCABB"
      flexoki-red-150 "#FDB2A2"
      flexoki-red-200 "#F89A8A"
      flexoki-red-300 "#E8705F"
      flexoki-red-400 "#D14D41"
      flexoki-red-500 "#C03E35"
      flexoki-red-600 "#AF3029"
      flexoki-red-700 "#942822"
      flexoki-red-800 "#6C201C"
      flexoki-red-850 "#551B18"
      flexoki-red-900 "#3E1715"
      flexoki-red-950 "#261312")

;; Orange
(setq flexoki-orange-50 "#FFE7CE"
      flexoki-orange-100 "#FED3AF"
      flexoki-orange-150 "#FCC192"
      flexoki-orange-200 "#F9AE77"
      flexoki-orange-300 "#EC8B49"
      flexoki-orange-400 "#DA702C"
      flexoki-orange-500 "#CB6120"
      flexoki-orange-600 "#BC5215"
      flexoki-orange-700 "#9D4310"
      flexoki-orange-800 "#71320D"
      flexoki-orange-850 "#59290D"
      flexoki-orange-900 "#40200D"
      flexoki-orange-950 "#27180E")

;; Yellow
(setq flexoki-yellow-50 "#FAEEC6"
      flexoki-yellow-100 "#F6E2A0"
      flexoki-yellow-150 "#F1D67E"
      flexoki-yellow-200 "#ECCB60"
      flexoki-yellow-300 "#DFB431"
      flexoki-yellow-400 "#D0A215"
      flexoki-yellow-500 "#BE9207"
      flexoki-yellow-600 "#AD8301"
      flexoki-yellow-700 "#8E6B01"
      flexoki-yellow-800 "#664D01"
      flexoki-yellow-850 "#503D02"
      flexoki-yellow-900 "#3A2D04"
      flexoki-yellow-950 "#241E08")

; Green
(setq flexoki-green-50 "#EDEECF"
      flexoki-green-100 "#DDE2B2"
      flexoki-green-150 "#CDD597"
      flexoki-green-200 "#BEC97E"
      flexoki-green-300 "#A0AF54"
      flexoki-green-400 "#879A39"
      flexoki-green-500 "#768D21"
      flexoki-green-600 "#66800B"
      flexoki-green-700 "#536907"
      flexoki-green-800 "#3D4C07"
      flexoki-green-850 "#313D07"
      flexoki-green-900 "#252D09"
      flexoki-green-950 "#1A1E0C")

;; Cyan
(setq flexoki-cyan-50 "#DDF1E4"
      flexoki-cyan-100 "#BFE8D9"
      flexoki-cyan-150 "#A2DECE"
      flexoki-cyan-200 "#87D3C3"
      flexoki-cyan-300 "#5ABDAC"
      flexoki-cyan-400 "#3AA99F"
      flexoki-cyan-500 "#2F968D"
      flexoki-cyan-600 "#24837B"
      flexoki-cyan-700 "#1C6C66"
      flexoki-cyan-800 "#164F4A"
      flexoki-cyan-850 "#143F3C"
      flexoki-cyan-900 "#122F2C"
      flexoki-cyan-950 "#101F1D")

;; Blue
(setq flexoki-blue-50 "#E1ECEB"
      flexoki-blue-100 "#C6DDE8"
      flexoki-blue-150 "#ABCFE2"
      flexoki-blue-200 "#92BFDB"
      flexoki-blue-300 "#66A0C8"
      flexoki-blue-400 "#4385BE"
      flexoki-blue-500 "#3171B2"
      flexoki-blue-600 "#205EA6"
      flexoki-blue-700 "#1A4F8C"
      flexoki-blue-800 "#163B66"
      flexoki-blue-850 "#133051"
      flexoki-blue-900 "#12253B"
      flexoki-blue-950 "#101A24")

;; Purple
(setq flexoki-purple-50 "#F0EAEC"
      flexoki-purple-100 "#E2D9E9"
      flexoki-purple-150 "#D3CAE6"
      flexoki-purple-200 "#C4B9E0"
      flexoki-purple-300 "#A699D0"
      flexoki-purple-400 "#8B7EC8"
      flexoki-purple-500 "#735EB5"
      flexoki-purple-600 "#5E409D"
      flexoki-purple-700 "#4F3685"
      flexoki-purple-800 "#3C2A62"
      flexoki-purple-850 "#31234E"
      flexoki-purple-900 "#261C39"
      flexoki-purple-950 "#1A1623")

;; Magenta
(setq flexoki-magenta-50 "#FEE4E5"
      flexoki-magenta-100 "#FCCFDA"
      flexoki-magenta-150 "#F9B9CF"
      flexoki-magenta-200 "#F4A4C2"
      flexoki-magenta-300 "#E47DA8"
      flexoki-magenta-400 "#CE5D97"
      flexoki-magenta-500 "#B74583"
      flexoki-magenta-600 "#A02F6F"
      flexoki-magenta-700 "#87285E"
      flexoki-magenta-800 "#641F46"
      flexoki-magenta-850 "#4F1B39"
      flexoki-magenta-900 "#39172B"
      flexoki-magenta-950 "#24131D")

;; --------------------------------------------------
;; Rosé Pine Dawn (https://rosepinetheme.com/palette/ingredients/)

(setq rose-base "#faf4ed"
      rose-surface "#fffaf3"
      rose-overlay "#f2e9e1"
      rose-muted "#9893a5"
      rose-subtle "#797593"
      rose-text "#575279"
      rose-love "#b4637a"
      rose-gold "#ea9d34"
      rose-rose "#d7827e"
      rose-pine "#286983"
      rose-foam "#56949f"
      rose-iris "#907aa9"
      rose-highlight-low "#f4ede8"
      rose-highlight-med "#dfdad9"
      rose-highlight-high "#cecacd")

;; --------------------------------------------------
;; Nightfox https://github.com/EdenEast/nightfox.nvim
;; Note: Names are based on the ANSI colors

(setq ansi-color-black "#4A4452"
      ansi-color-bright-black "#7A7480"
      ansi-color-red "#B85868"
      ansi-color-bright-red "#C96878"
      ansi-color-green "#6E8A4A"
      ansi-color-bright-green "#82A056"
      ansi-color-yellow "#B58820"
      ansi-color-bright-yellow "#C99528"
      ansi-color-blue "#4F77A8"
      ansi-color-bright-blue "#6088B8"
      ansi-color-magenta "#8E5A98"
      ansi-color-bright-magenta "#9F6AA8"
      ansi-color-cyan "#4A8A85"
      ansi-color-bright-cyan "#5AA098"
      ansi-color-white "#C8BFAE"
      ansi-color-bright-white "#DED7C5"
      color-background "#FFFCEF"
      color-dark-background "#F5EFDD"
      color-region "#F5EFDD")

(provide 'colors)
