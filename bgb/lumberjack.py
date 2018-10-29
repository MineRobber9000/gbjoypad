from colorama import init, Fore, Style
ENDF = Style.RESET_ALL

COLORS = {"*":"cyan","!":"yellow","X":"red"}
def log(s,p="*",c=None):
        if c is None:
                c = COLORS.get(p,None)
        c = getattr(Fore,c.upper())
        print(c+"[{}] {}".format(p,s)+ENDF)
