#!/usr/bin/env python

import pygame, sys,os, random
from pygame.locals import * 

def instructions():
    screen.fill((0, 0, 0))
    text1=font.render("As explained, please bid on each of the following items",1,white)
    text2=font.render("by clicking on the amount on the bar below",1,white)
    text3=font.render("Please click to continue..",1,white)
    textpos1=text1.get_rect(centerx=width/2, centery=height/2-40)
    textpos2=text2.get_rect(centerx=width/2, centery=height/2)
    textpos3=text3.get_rect(centerx=width/2, centery=height/2+60)
    screen.blit(text1, textpos1)
    screen.blit(text2, textpos2)
    screen.blit(text3, textpos3)
    pygame.display.flip()
    while 1:
        event=pygame.event.poll()
        if event.type==MOUSEBUTTONDOWN:
            pygame.event.clear()
            break

def display_trial(stim,pos):
    file = os.path.join("stim",stim)
    pic=pygame.image.load(file).convert()
    screen.fill((0, 0, 0))
    pygame.draw.rect(screen, white, rect)
    text=font.render("$0                 $1                 $2                 $3",1,white)
    textpos=text.get_rect(centerx=width/2, centery=height-30)
    screen.blit(text, textpos)
    screen.blit(pic,pic.get_rect(centerx=width/2, centery=height/2))
    draw_marker(pos)
    pygame.display.flip()
    
def draw_marker(pos):
    marker = pygame.Rect(pos-2,(height-75),4,30)
    pygame.draw.rect(screen, blue, marker)
    pygame.display.flip()

def get_response():
    pygame.event.clear()
    while 1:
        event=pygame.event.poll()
        pos = pygame.mouse.get_pos()
        if pos[0] > width/2-225 and pos[0] < width/2+225 and pos[1]>height-70 and pos[1]<height-50:
            display_trial(stim,pos[0])
        
        
        if pygame.key.get_pressed()[K_LSHIFT] and pygame.key.get_pressed()[K_BACKQUOTE]:
            raise SystemExit
        if pygame.key.get_pressed()[K_LSHIFT] and pygame.key.get_pressed()[K_EQUALS]:
            save_image()
        if event.type==MOUSEBUTTONUP:
            pos = pygame.mouse.get_pos()
            if pos[0] > width/2-225 and pos[0] < width/2+225 and pos[1]>height-70 and pos[1]<height-50:
                bet=(pos[0]-(width/2-225))/150.0
                return bet
                break

def write_header():
    sd=("Trial"+'\t'+"StimName"+'\t'+"Bid"+'\t'+"RT"+'\n')
    sepname=subjid+"_BDM2.txt"
    sep_path=os.path.join("Output",sepname)
    sepfile=open(sep_path, "a")
    sepfile.write(sd)
    sepfile.close()

def write_response(trial,bet,rt):
    sd=(str(trial)+'\t'+stim+'\t'+str(bet)+'\t'+str(rt)+'\n')
    sepname=subjid+"_BDM2.txt"
    sep_path=os.path.join("Output",sepname)
    sepfile=open(sep_path, "a")
    sepfile.write(sd)
    sepfile.close()

def intertrial():
    screen.fill((0, 0, 0))
    text=font2.render("+",1,white)
    textpos=text.get_rect(centerx=width/2, centery=height/2)
    screen.blit(text, textpos)
    pygame.display.flip()
    pygame.time.wait(1000)

def end():
    screen.fill((0, 0, 0))
    text=font2.render("Thank you! Please get the experimenter.",1,yellow)
    textpos=text.get_rect(centerx=width/2, centery=height/2)
    screen.blit(text, textpos)
    pygame.display.flip()
    pygame.time.wait(5000)

subjid=sys.argv[1]

pygame.init()

# Set up variables
screen = pygame.display.set_mode((1280,800), FULLSCREEN)
white = (255, 255, 255)
yellow = (255, 255, 0)
blue=(0,0,255)
height=screen.get_height()
width=screen.get_width()
font = pygame.font.Font(None, 36)
font2 = pygame.font.Font(None, 72)
rect = pygame.Rect((width/2-225),(height-70),450,20)

#JR=["jollyrancherblue", "jollyranchergreen", "jollyrancherpurple", "jollyrancherred"]
#random.shuffle(JR)
#Pringles=[ "Pringles", "PringlesRed", "pringlescheezums"]
#random.shuffle(Pringles)
#keebler=["keeblerfudgestripes", "keeblerrainbow"]
#random.shuffle(keebler)

#stimulus list of 56 items
stimlist=stimlist=["100grand_small.bmp", "KitKat_small.bmp", "3Musketeers.bmp", "Laffytaffyred_one.bmp", "Almondjoy.bmp", "Laysclassic.bmp", "AnimalCrackers.bmp", "Lollipopred.bmp", "BabyRuth.bmp", "Milano.bmp", "Butterfinger.bmp", "Milkduds.bmp", "CheesyDoritos.bmp", "MilkyWay.bmp", "Cheetos.bmp", "MrGoodbar.bmp", "Cheezits.bmp", "Nutterbutter.bmp", "ChipsAhoy_small.bmp", "Oreos.bmp", "Chocolate_mm.bmp", "PayDay.bmp", "Crunch.bmp", "PeanutMMs.bmp", "Doritosranch.bmp", "PopTartsCinnamon.bmp", "Dots_one.bmp", "PopTartsStrawberry.bmp", "FamousAmos_small.bmp", "PringlesRed.bmp", "FigNewton_small.bmp", "Reeses.bmp", "FlamingCheetos.bmp", "Riprolls.bmp", "Fritos.bmp", "RitzBitz2.bmp", "FrootLoops.bmp", "Skittles.bmp", "Funyuns_small.bmp", "Slimjim.bmp", "Ghiradelli_milk.bmp", "Snickers.bmp", "Ghiradelli_milk_Almonds.bmp", "Redvines_small.bmp", "Goldfish.bmp", "SourSkittles.bmp", "Granolabar.bmp", "Sourpatch.bmp", "Hersheykisses.bmp", "Hersheymilk_several.bmp", "TeddyGrahamschocolate.bmp", "Toberlorone.bmp", "Jollyrancherred.bmp", "Twix.bmp", "Keeblerfudgestripes.bmp", "Whatchamacallit.bmp"]
random.shuffle(stimlist)

sd=("Trial"+'\t'+"StimName"+'\t'+"Bid"+'\t'+"RT"+'\n')
sepname=subjid+"_stimlist.txt"
sep_path=os.path.join("Output",sepname)
sepfile=open(sep_path, "a")
sepfile.write('\t'.join(stimlist))
sepfile.close()
trial=1

instructions()
write_header()
for stim in stimlist:

    pygame.mouse.set_pos(width/2,height/2)
    stimonset=pygame.time.get_ticks()
    display_trial(stim,(width/2))
  
    pygame.time.wait(500)

    bet=get_response()
    rt=pygame.time.get_ticks()-stimonset
    write_response(trial,bet,rt)
    
    intertrial()
    trial=trial+1
end()


