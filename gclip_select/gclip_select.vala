/*
	Copyright 2011 Li-Cheng (Andy) Tai
                      atai@atai.org
                      
	gclip_select is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation, either version 3 of the License, or (at your option)
	any later version.

	gclip_select is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with gclip_select. If not, see http://www.gnu.org/licenses/.


*/

using GLib;
using Pango;
using Gtk;
using Gee;

bool self_set = false;
Clipboard clip;

HashMap<string, TreeIter?> content_table ;

void setup_list_box(Gtk.TreeView list_box)
{
	var list_model = new ListStore(1, typeof(string));
	list_box.set_rules_hint(true);
	list_box.set_model(list_model);
	CellRendererText text_renderer = new CellRendererText();
	text_renderer.ellipsize_set = true;
	text_renderer.ellipsize = Pango.EllipsizeMode.END;
	
	list_box.insert_column_with_attributes(-1, "Clip content Selector", text_renderer, "text", 0);
	list_box.set_headers_visible(false);
	TreeSelection selection = list_box.get_selection();
	
	selection.changed.connect(() =>
	{
		
		TreeIter iter;
		TreeModel model;
		string content;
		if (selection.get_selected(out model, out iter))
		{
			list_model.get(iter, 0, out content, -1);
			clip.set_text(content, -1);
			self_set = true;
		}
	});
}

void add_entry_to_list_box(TreeView list_box, string content)
{
	TreeIter iter;
	string cksum = Checksum.compute_for_string(GLib.ChecksumType.SHA256, content);
	if (content_table.has_key(cksum))
	{
		iter = content_table[cksum];
	
	}
	else
	{
		
		ListStore list_model = (ListStore) list_box.get_model();
		list_model.append(out iter);
		
		list_model.set(iter, 0, content);	
		content_table[cksum] = iter;
	}
	TreeSelection selection = list_box.get_selection();
	selection.select_iter(iter);

} 

void delete_current_selection(TreeView list_box)
{
	TreeSelection selection = list_box.get_selection();
	TreeIter iter;
	TreeModel model;
	if (selection.get_selected(out model, out iter))
	{
		ListStore list_model = (ListStore) model;
		selection.unselect_iter(iter);
		list_model.remove(iter);
	}
}

void delete_all_selection(TreeView list_box)
{
	ListStore list_model = (ListStore) list_box.get_model();
	TreeSelection selection = list_box.get_selection();
	selection.unselect_all();
	list_model.clear();

}

int main(string[] args)
{
	Gtk.init(ref args);
	
	content_table = new HashMap<string, TreeIter?>();
	
	Gtk.Window window = new Window();
	Gtk.Button delete_button, delete_all_button;
	Gtk.HBox panel = new Gtk.HBox(false, 4);
	
	window.title = "Clipboard Selection Manager";
	Gtk.VBox vbox = new Gtk.VBox(false, 10);
	
	Gtk.ScrolledWindow list_view = new ScrolledWindow(null, null);
	
	list_view.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
	list_view.set_shadow_type(Gtk.ShadowType.ETCHED_IN);
	
	Gtk.TreeView list_box = new TreeView();
	setup_list_box(list_box);
	list_view.add(list_box);
	vbox.pack_start(list_view);
	
	
	delete_button = new Button.with_label("Delete");
	
	delete_button.released.connect( () =>
	{
		delete_current_selection(list_box);
	} );
	
	delete_all_button = new Button.with_label("Delete All");
	delete_all_button.released.connect( () =>
	{
		delete_all_selection(list_box);
	} );
   
	panel.pack_start(delete_button, false, false);
	panel.pack_start(delete_all_button, false, false);
	
	vbox.pack_end(panel, false, false);
	window.add(vbox);
	window.set_default_size(200, 200);
	window.show_all();
	
	clip = Clipboard.get(Gdk.SELECTION_PRIMARY);
	string content = clip.wait_for_text();
	if (content != null)
		add_entry_to_list_box(list_box, content);
	
	window.destroy.connect(Gtk.main_quit);
	
	clip.owner_change.connect((e) =>
	{
		if (!self_set)
		{
		content = clip.wait_for_text();
		add_entry_to_list_box(list_box, content);
	    }
		else
			self_set = false;
	});
	
	Gtk.main();
	return 0;
}

