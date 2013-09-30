AUTOMAKE_OPTIONS = foreign

AM_CFLAGS = $(GUI_CFLAGS)
AM_VALAFLAGS = -g --save-temps --pkg "gtk+-3.0" --pkg "glib-2.0" --pkg gee-0.8 --pkg pango

bin_PROGRAMS = gclip_select

gclip_select_SOURCES = gclip_select.vala

gclip_select_LDADD = $(GUI_LIBS)

dist_doc_DATA = README LICENSE

ACLOCAL_AMFLAGS = -I m4

