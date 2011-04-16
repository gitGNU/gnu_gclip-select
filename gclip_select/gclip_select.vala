/*
    Copyright 2011 Li-Cheng (Andy) Tai

    gclip_select is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the Free
    Software Foundation, either version 3 of the License, or (at your option)
    any later version.

    gclip_select is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
    more details.

    You should have received a copy of the GNU General Public License along with
    gclip_select. If not, see http://www.gnu.org/licenses/.


*/

using GLib;
using Gtk;
using Gee;

bool self_set = false;
Clipboard clip;

HashMap<string, TreeIter?> content_table ;

void setup_list_view(Gtk.TreeView list_view)
{
    var list_model = new ListStore(1, typeof(string));
    list_view.set_model(list_model);
    
    list_view.insert_column_with_attributes(-1, "Clip content Selector", new CellRendererText(), "text", 0);
    list_view.set_headers_visible(false);
    TreeSelection selection = list_view.get_selection();
    
    selection.changed.connect(() =>
    {
        
        TreeIter iter;
        TreeModel model;
        string content;
        selection.get_selected(out model, out iter);
        list_model.get(iter, 0, out content, -1);
        clip.set_text(content, -1);
        self_set = true;
    
    });
}

void add_entry_to_list_view(TreeView list_view, string content)
{
    TreeIter iter;
    string cksum = Checksum.compute_for_string(GLib.ChecksumType.SHA256, content);
    if (content_table.has_key(cksum))
    {
        iter = content_table[cksum];
    
    }
    else
    {
		
		ListStore list_model = (ListStore) list_view.get_model();
		list_model.append(out iter);
		
		list_model.set(iter, 0, content);   
		content_table[cksum] = iter;
    }
    TreeSelection selection = list_view.get_selection();
    selection.select_iter(iter);

}

int main(string[] args)
{
    Gtk.init(ref args);
    
    content_table = new HashMap<string, TreeIter?>();
    
    Gtk.Window window = new Window();
    window.title = "Clipboard Selection Manager";
    Gtk.TreeView list_view = new TreeView();
    setup_list_view(list_view);
    window.add(list_view);
    window.set_default_size(200, 200);
    window.show_all();
    
    clip = Clipboard.get(Gdk.SELECTION_PRIMARY);
    string content = clip.wait_for_text();
    if (content != null)
        add_entry_to_list_view(list_view, content);
    
    window.destroy.connect(Gtk.main_quit);
    
    clip.owner_change.connect((e) =>
    {
        if (!self_set)
        {
	    content = clip.wait_for_text();
	    add_entry_to_list_view(list_view, content);
	}
        else
            self_set = false;
    });
    
    Gtk.main();
    return 0;
}

