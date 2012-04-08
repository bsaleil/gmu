
COMPIL=valac
EXEC=gmu
LIBS= --pkg gtk+-3.0

all : gmu
	
gmu : gmu.vala window.glade
	$(COMPIL) gmu.vala $(LIBS) -o $(EXEC)

clean : 
	rm $(EXEC)
