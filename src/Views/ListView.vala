namespace Notejot {
    public class Views.ListView : Gtk.ListBox {
        private MainWindow win;
        Gtk.GestureMultiPress press;
        public bool is_modified {get; set; default = false;}

        public string search_text = "";

        public ListView (MainWindow win) {
            this.win = win;
            this.vexpand = true;
            is_modified = false;
            this.show_all ();
            this.set_selection_mode (Gtk.SelectionMode.SINGLE);
            this.set_activate_on_single_click (true);
            this.get_style_context ().add_class ("notejot-view");

            set_filter_func (do_filter_list);

            var empty_state = new Hdy.StatusPage ();
            empty_state.visible = true;
            empty_state.icon_name = "document-new-symbolic";
            empty_state.title = _("No Notes");
            empty_state.description = _("Use the + button to add a note.");

            this.set_placeholder (empty_state);

            this.row_selected.connect ((selected_row) => {
                win.leaflet.set_visible_child (win.grid);
                win.settingmenu.visible = true;
                win.settingmenu.no_show_all = false;

                if (((Widgets.Note)selected_row) != null) {
                    ((Widgets.Note)selected_row).textfield.grab_focus ();
                    ((Widgets.Note)selected_row).select_item ();
                    win.settingmenu.controller = ((Widgets.Note)selected_row);
                } else {
                    win.settingmenu.no_show_all = true;
                }
            });

            press = new Gtk.GestureMultiPress (this);
            press.button =Gdk.BUTTON_SECONDARY;

            press.pressed.connect ((gesture, n_press, x, y) => {
                if (n_press > 1) {
                    press.set_state (Gtk.EventSequenceState.DENIED);
                    return;
                }

                var row = get_row_at_y ((int)y);

                if (row == null) {
                    press.set_state (Gtk.EventSequenceState.DENIED);
                    return;
                }

                var popover = new Widgets.NoteMenuPopover ();
                ((Widgets.Note)row).popover_listener (popover);

                popover.set_relative_to (((Widgets.Note)row));
                popover.popup ();

                press.set_state (Gtk.EventSequenceState.CLAIMED);
            });
        }

        public void set_search_text (string search_text) {
            this.search_text = search_text;
            invalidate_filter ();
        }

        protected bool do_filter_list (Gtk.ListBoxRow row) {
            if (search_text.length > 0) {
                if (((Widgets.Note)row).log.notebook.contains (search_text)) {
                    return ((Widgets.Note)row).log.notebook.contains (search_text);
                } else {
                    return ((Widgets.Note)row).get_title ().down ().contains (search_text);
                }
            }

            return true;
        }

        public GLib.List<unowned Widgets.Note> get_rows () {
            return (GLib.List<unowned Widgets.Note>) this.get_children ();
        }

        public void clear_column () {
            foreach (Gtk.Widget item in this.get_children ()) {
                item.destroy ();
            }
        }
    }
}
