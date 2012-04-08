using Gtk;
using GLib.Process;

class Gui
{
	const string GLADE = "window.glade";
	Gtk.Builder builder;
	
	private Gtk.Window window;	
	
	public Gui()
	{
		// Open glade file to buil window
		builder = new Gtk.Builder();
		try {
		builder.add_from_file(GLADE);
		} catch (Error e){}
		window = builder.get_object("window") as Gtk.Window;
		window.show();
		window.destroy.connect(Gtk.main_quit);
		
		Gtk.Button b = builder.get_object("button_src") as Gtk.Button;
		b.pressed.connect(browseSrc);
		b = builder.get_object("button_dst") as Gtk.Button;
		b.pressed.connect(browseDst);
		b = builder.get_object("button_mount") as Gtk.Button;
		b.pressed.connect(mount);
		b = builder.get_object("button_umount") as Gtk.Button;
		b.pressed.connect(umount);
	}
	
	public void umount()
	{
		Gtk.Entry entry_dst = builder.get_object("entry_dst") as Gtk.Entry;
		
		// Try to umount
		if (entry_dst.get_text() != "")
		{
			string command = "gksudo \"umount ";
			string output = "";
			string error = "";
			int status;
			command += entry_dst.get_text() + "\" -D Gmu";
			
			try {
			spawn_command_line_sync(command,out output,out error,out status);
			} catch (SpawnError e){}
			
			if (status == 0)
				displayDialog("Image unmounted",Gtk.MessageType.INFO);
			else
				displayDialog("Error while unmounting",Gtk.MessageType.ERROR);
		}
		// Empty field
		else
		{
			displayDialog("Error : Empty field",Gtk.MessageType.ERROR);
		}
	}
	
	public void mount()
	{
		Gtk.Entry entry_src = builder.get_object("entry_src") as Gtk.Entry;
		Gtk.Entry entry_dst = builder.get_object("entry_dst") as Gtk.Entry;
		
		// Try to mount
		if (entry_src.get_text() != "" && entry_dst.get_text() != "" )
		{
			string command = "";
			string output = "";
			string error = "";
			int status;
			
			command += "gksudo \"mount -o loop -t iso9660 ";
			command += entry_src.get_text() + " ";
			command += entry_dst.get_text() + "\" -D Gmu";
			
			try {
			spawn_command_line_sync(command, out output, out error, out status);
			} catch(SpawnError e){}
			
			if (output != "")
				displayDialog("Image mounted.\n"+output,Gtk.MessageType.INFO);
			else if (error != "")
				displayDialog(error,Gtk.MessageType.ERROR);
			else if (status == 0)
				displayDialog("Image mounted.",Gtk.MessageType.INFO);
			else
				displayDialog("Error while mounting.",Gtk.MessageType.ERROR);
		}
		// Empty field
		else
		{
			displayDialog("Error : Empty field",Gtk.MessageType.ERROR);
		}
	}
	
	public void browseSrc()
	{
		Gtk.FileChooserDialog f = new Gtk.FileChooserDialog("Browse...",window,FileChooserAction.OPEN,null);
		
		Gtk.FileFilter filter = new Gtk.FileFilter();
		filter.set_filter_name("ISO images");
		filter.add_mime_type("application/x-iso9660-image");
		f.add_filter(filter);
		f.add_button(Gtk.Stock.CANCEL,ResponseType.CANCEL);
		f.add_button(Gtk.Stock.OPEN, ResponseType.OK);
		
		if (f.run() == ResponseType.OK)
		{
			Gtk.Entry e = builder.get_object("entry_src") as Gtk.Entry;
			e.set_text(f.get_filename());
		}
		f.destroy();
	}
	
	public void browseDst()
	{
		Gtk.FileChooserDialog f = new Gtk.FileChooserDialog("Browse...",window,FileChooserAction.SELECT_FOLDER,null);
		f.add_button(Gtk.Stock.CANCEL,ResponseType.CANCEL);
		f.add_button(Gtk.Stock.OPEN, ResponseType.OK);
		
		if (f.run() == ResponseType.OK)
		{
			Gtk.Entry e = builder.get_object("entry_dst") as Gtk.Entry;
			e.set_text(f.get_filename());
		}
		f.destroy();
	}
	
	private void displayDialog(string message, Gtk.MessageType t)
	{
		Gtk.MessageDialog d = new Gtk.MessageDialog(window,
		Gtk.DialogFlags.MODAL, t,
		Gtk.ButtonsType.CLOSE,message);			
		d.run();
		d.destroy();
	}
	
	public static int main(string[] args)
	{
		Gtk.init (ref args);
		Gui g = new Gui();
		Gtk.main ();
		return 0;
	}
}
