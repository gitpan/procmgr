#!/usr/local/bin/perl
################################################################################
##                                                                            ##
## Author     : Monty Scroggins                                               ##
## Description: GUI Frontend to manipulating processes                        ##
##                                                                            ##
##                                                                            ##
##                                                                            ##
##  Parameters:                                                               ##
##                                                                            ##
## +++++++++++++++++++++++++++ Maintenance Log ++++++++++++++++++++++++++++++ ##
## Thu Apr 30 17:33:28 CDT 1998  Monty Scroggins - Script created.                                
## Wed May  6 17:23:37 CDT 1998  Monty Scroggins - Changed font for Hp's
################################################################################
use Tk;
use Tk::Dialog;
use Tk::SplitFrame;
use Tk::ComboEntry;

#perl variables
$|=1; # set output buffering to off
$[ = 0; # set array base to 1
$, = ' '; # set output field separator
$\ = "\n"; # set output record separator

#The colors
$txtbackground="snow2";
$background="bisque3";
$troughbackground="bisque4";
$buttonbackground="tan";
$txtforeground="black";
$winfont="8x13bold";
$trbgd="bisque4";

#initial values for the count of slected processes and the kill status
$selprocs=0;
$killstat="Ready..";
@killlist="";
$sortval=0;

#default filter flag set to info
$filterflag="info";

#null out the history list for the filter dialog
my @filterlist=""; 

#Alpha strings to prepend to the sortdate.  This will group
#all of the months together in a calendar order..  A normal alpha sort
#will jumble the months..  Dec before Nov etc..
%months=(
"Jan"=>"AA",
"Feb"=>"BB",
"Mar"=>"CC",
"Apr"=>"DD",
"May"=>"EE",
"Jun"=>"FF",
"Jul"=>"GG",
"Aug"=>"HH",
"Sep"=>"II",
"Oct"=>"JJ",
"Nov"=>"KK",
"Dec"=>"LL");

$LW = Tk::MainWindow->new;
#$LW->minsize(30,24);
$LW->minsize(30,28);
$LW->maxsize(46,28);

#set the window title
$LW->configure(
  -title=>"Process Manager",
  -background=>$background,
  -foreground=>$txtforeground,
  -borderwidth=>2,
  -relief=>'raised',
  );


#create two sub frames - one for the text, one for the buttons, and one for help,cancel
#label frame 
$listframe1=$LW->Frame(
  -borderwidth=>'0',
  -relief=>'flat',
  -background=>$background,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  )->pack(
    -fill=>'x',
    -pady=>0,
    -padx=>0,
    );

#the split frame with the slider between the panes
$mainsplit=$LW->SplitFrame(
  -borderwidth=>'0',
  -relief=>'flat',
  -bg=>'red4',
  -background=>$background,
  -trimcolor=>$background,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -orientation=>'horizontal',
  -sliderposition=>380,
  -padbefore=>80,
  -padafter => 105,
  -trimcount=>2,
  -sliderwidth=>7,
  -opaque=>1,
  )->pack(
    -fill=>'both',
    -expand=>'true',
    -pady=>'0',
    -padx=>'0',
    );

#listbox frame
$listframe2top=$mainsplit->Frame(
  -borderwidth=>'0',
  -relief=>'flat',
  -background=>$background,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  )->pack(
    -fill=>'both',
    -expand=>'true',
    -pady=>'0',
    -padx=>'0',
    );

#listbox frame
$listframe2bot=$mainsplit->Frame(
  -borderwidth=>'0',
  -relief=>'flat',
  -background=>$background,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  )->pack(
    -expand=>'true',
    -fill=>'both',
    -pady=>'0',
    -padx=>'0',
    );

#buttons frame
$listframe3=$LW->Frame(
  -borderwidth=>1,
  -relief=>'sunken',
  -background=>$background,
  -foreground=>$txtforeground,
  -highlightthickness=>0)
  ->pack(
    -fill=>'x',
    -pady=>3,
    -padx=>0,
    );


########################################################
#the top row of buttons used to select the sort column

$listframe1->Button(
  -text=>"Login",
  -background=>$background,
  -foreground=>$txtforeground,
  -font=>'8x13bold',
  -borderwidth=>1,
  -width=>7,
  -highlightthickness=>0,
  -relief=>'raised',
  -command=>sub{$sortval=0;&populate_list($sortval,'none')},
  )->pack(
    -side=>'left',
    );
    
$listframe1->Button(
  -text=>"PID",
  -background=>$background,
  -foreground=>$txtforeground,
  -font=>'8x13bold',
  -borderwidth=>1,
  -width=>6,
  -highlightthickness=>0,
  -relief=>'raised',
  -command=>sub{$sortval=1;&populate_list($sortval,'none')},
  )->pack(
    -side=>'left',
    );
    
$listframe1->Button(
  -text=>"Date",
  -background=>$background,
  -foreground=>$txtforeground,
  -font=>'8x13bold',
  -borderwidth=>1,
  -justify=>'left',
  -width=>7,
  -highlightthickness=>0,
  -relief=>'raised',
  -command=>sub{$sortval=2;&populate_list($sortval,'none')},  
  )->pack(
    -side=>'left',
    );

$listframe1->Button(
  -text=>"Process Information   ",
  -background=>$background,
  -foreground=>$txtforeground,
  -font=>'8x13bold',
  -borderwidth=>1,
  -highlightthickness=>0,
  -relief=>'raised',
  -command=>sub{$sortval=3;&populate_list($sortval,'none')},
  )->pack(
    -side=>'left',
    -expand=>1,
    -fill=>'x',
    );
    
########################################################
# Create a scrollbar on the right side of the listbox

$scroll=$listframe2top->Scrollbar(
  -orient=>'vert',
  -elementborderwidth=>1,
  -highlightthickness=>0,
  -background=>$background,
  -troughcolor=>$troughbackground,
  -relief=>'flat',)
  ->pack(
    -side=>'right',
    -fill=>'y',
    );

$lwproclist=$listframe2top->Listbox(
  -yscrollcommand=>['set', $scroll],
  -relief=>'sunken',
  -font=>'8x13bold',
  -highlightthickness=>0,
  -background=>$txtbackground,
  -foreground=>$txtforeground,
  -selectforeground=>$txtforeground,
  -selectbackground=>'#c0d0c0',
  -borderwidth=>1,
  -selectmode=>'extended',
  -setgrid=>'yes',
  )->pack(
    -fill=>'both',
    -expand=>1,
    );

$scroll->configure(-command=>['yview', $lwproclist]);
$lwproclist->bind('<Double-1>'=>\&pushkill);
$lwproclist->bind('<Button-3>'=>\&pushkill);

# Create a scrollbar on the right side and bottom of the listbox
$botscroll=$listframe2bot->Scrollbar(
  -orient=>'vert',
  -elementborderwidth=>1,
  -highlightthickness=>0,
  -background=>$background,
  -troughcolor=>$troughbackground,
  -relief=>'flat',
  )->pack(
    -side=>'right',
    -fill=>'y',
    -pady=>0,
    );

$bottproclist=$listframe2bot->Listbox(
  -yscrollcommand=>['set', $botscroll],
  -relief=>'sunken',
  -font=>'8x13bold',
  -highlightthickness=>0,
  -background=>$txtbackground,
  -foreground=>'#a00000',
  -selectforeground=>$txtforeground,
  -selectbackground=>'#c0d0c0',
  -borderwidth=>1,
  -height=>6,
  )->pack(
    -fill=>'both',
    -expand=>1,
    -pady=>0,
    );
# 
$botscroll->configure(-command=>['yview', $bottproclist]);
$bottproclist->bind('<Double-1>' =>\&popkill);

########################################################
#bottom row of buttons and labels

#Processes frame
$procframe=$listframe3->Frame(
  -borderwidth=>1,
  -relief=>'sunken',
  -background=>$background,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  )->pack(
    -fill=>'both',
    -pady=>0,
    -padx=>0,
    -expand=>1,
    );


$listframe3->Button(
  -text=>'Nuke it!',
  -borderwidth=>'1',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -font=>$winfont,
  -width=>10,
  -command=>\&sel_nuke_proc,
  )->pack(
    -side=>'left',
    -padx=>0,
    -pady=>3,
    -expand=>0,
    );

$listframe3->Button(
  -text=>'Proc Info',
  -borderwidth=>'1',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -font=>$winfont,
  -width=>10,
  -command=>\&whois_it,
  )->pack(
    -side=>'left',
    -padx=>0,
    -pady=>3,
    -expand=>0,
    );
    
$menu_cb = '~Login';
$mb=$listframe3->Menubutton(
  -text=>'Select By',
  -borderwidth=>'1',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -font=>$winfont,
  -width=>10,
  -relief=>'raised',
  -indicatoron=>1,
  -tearoff=>0,
  )->pack(
    -side=>'left',
    -padx=>0,
    -pady=>3,
    -expand=>0,
    -fill=>'y'
    ); 

$mb->command(
  -label=>'Login',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -font=>$winfont,
  -command=>[\&multi_select, 'uid'],
  );
  
$mb->command(
  -label=>'Date',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -font=>$winfont,
  -command=>[\&multi_select, 'date'],
  );

$mb->command(
  -label=>'Description    ',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -font=>$winfont,
  -command=>[\&multi_select, 'info'],
  );
  
$listframe3->Button(
  -text=>'Add Multi',
  -borderwidth=>'1',
  -width=>'10',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -font=>$winfont,
  -command=>\&pushkill,
  )->pack(
    -side=>'left',
    -padx=>0,
    -pady=>3,
    );

$filterbutton=$listframe3->Button(
  -text=>'Filter',
  -borderwidth=>'1',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -font=>$winfont,
  -width=>10,
  -command=>\&filter_win,
  )->pack(
    -side=>'left',
    -padx=>0,
    -pady=>3,
    -expand=>0,
    );

     
$listframe3->Button(
  -text=>'Clear Kills',
  -borderwidth=>'1',
  -width=>'10',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -font=>$winfont,
  -command=>\&clear_kills,
  )->pack(
    -side=>'left',
    -padx=>0,
    -pady=>3,
    );
   
$procframe->Label(
  -text=>'Active Processes:',
  -borderwidth=>'1',
  -background=>$background,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -font=>$winfont,
  )->pack(
    -side=>'left',
    -padx=>1,
    -pady=>3,
    -expand=>0,
    );

$procframe->Label(
  -textvariable=>\$currprocs,
  -borderwidth=>'1',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -font=>$winfont,
  -relief=>'sunken',
  -width=>4,
  )->pack(
    -side=>'left',
    -padx=>4,
    -pady=>3,
    -expand=>0,
    );

$procframe->Label(
  -text=>'Selected Processes:',
  -borderwidth=>'1',
  -background=>$background,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -font=>$winfont,
  )->pack(
    -side=>'left',
    -padx=>4,
    -pady=>3,
    -expand=>0,
    );

$procframe->Label(
  -textvariable=>\$selprocs,
  -borderwidth=>'1',
  -background=>$buttonbackground,
  -foreground=>'#700000',
  -highlightthickness=>0,
  -font=>$winfont,
  -relief=>'sunken',
  -width=>4,
  )->pack(
    -side=>'left',
    -padx=>4,
    -pady=>3,
    -expand=>0,
    );

$ks=$procframe->Label(
  -textvariable=>\$killstat,
  -borderwidth=>'1',
  -background=>$background,
  -foreground=>'#004500',
  -highlightthickness=>0,
  -font=>$winfont,
  -relief=>'flat',
  -width=>14,
  )->pack(
    -side=>'left',
    -padx=>0,
    -pady=>3,
    -expand=>1,
    );

$listframe3->Button(
  -text=>'Cancel',
  -borderwidth=>'1',
  -width=>'10',
  -background=>$buttonbackground,
  -foreground=>$txtforeground,
  -highlightthickness=>0,
  -font=>$winfont,
  -command=>sub{exit;},
  )->pack(
    -side=>'right',
    -padx=>4,
    -pady=>3,
    );

&populate_list(0,'none');
$mainsplit->update;

MainLoop;


########################################################
#Subs

#sort rules used in the alpha sort command
#$a and $b are the internal variables used for the cmp or diff command.
#must handle numeric values differently than alpha values..
sub sort_criteria {
  $num_a=$a=~/^[0-9]/;
  $num_b=$b=~/^[0-9]/;
  if ($num_a && $num_b) {
    $retval = $a<=>$b;
    }elsif ($num_a) {
      $retval=1;
      }elsif ($num_b) {
        $retval=-1;
        }else{
          $retval = $a cmp $b;
          }
   $retval; 
}

#build the process list and populate the text widget
sub populate_list {
  @listout="";
  #There is a variable number of elements on the lines depending on the process
  #date, etc...   Some special handling has to be done to always parse a 
  #presentable string.
  ($colselect,$usefilter)=@_;
  @goodrecs="";
  $lwproclist->delete(0,'end');
  @listout=`p\s -ef`;
  shift(@listout);
  foreach (@listout) {
    ($uid,$pid,$t0,$t1,$t2,$t3,$t4,@info)=split(" ",$_);
    #padding 
    $uid.="             ";
    $uid=substr("$uid",0,8);
    #handle the pts values or the question marks
    if ($t3 =~ /^pts|^\?/) {$t3=" ";};
    #pad the display date with spaces for good alignment;
    $date="$t2 $t3                 ";
    #if the date string is a timestamp (the current day), prepend zzz's so we
    #will put the latest values on the bottom...
    if ($t2 =~ /^[0-9]/) {
      $sortdate="ZZZ$t2";
      }else {
        $sortdate=$months{$t2}.$t3;
         }
    $date=substr("$date",0,9);
    #more padding
    $pid .="             ";
    $pid=substr("$pid",0,8);
    #if the description text begins with a decimal number  blah blah
    #pull the first element off of the info array.
    if (@info[0] =~ /^\d.*:/) {
      shift (@info)
      }
     
    #if the column for sort is name  
    if ($colselect==0) {
      if ($usefilter eq "none") {
        push (@goodrecs,"$uid:-:$uid $pid $date @info");
        }else{
          if ($uid =~/$filterstring/) {
            push (@goodrecs,"$uid:-:$uid $pid $date @info");
            }
          }#else   
      }#if colselect
      
    #if the column for sort is PID  
    if ($colselect==1) {
      if ($usefilter eq "none") {
        push (@goodrecs,"$pid:-:$uid $pid $date @info");
        }else{
          if ($pid =~/$filterstring/) {      
            push (@goodrecs,"$pid:-:$uid $pid $date @info");
            }
          }#else
      }#if colselect
      
     #if the column for sort is date 
     if ($colselect==2) {
       if ($usefilter eq "none") {
         push  (@goodrecs,"$sortdate:-:$uid $pid $date @info");
         }else{
           if ($sortdate =~/$filterstring/) {            
             push  (@goodrecs,"$sortdate:-:$uid $pid $date @info");
             }
           }#else
       }#if colselect
    
    #if the column for sort is info 
    if ($colselect==3) {
      $foundininfo=0;
      if ($usefilter eq "none") {
        push  (@goodrecs,"@info:-:$uid $pid $date @info");
        }else{
          #since the info string is an array, have to check the whole array for 
          #the searchstring
          foreach (@info) {
            #if we found the string, no need to continue searching
            last if ($foundininfo==1);
            if ($_ =~/$filterstring/) {
              $foundininfo=1;  
              }#if
            }#foreach info
            #if the string was found, push the record onto the array
            if ($foundininfo ==1 ) {  
              push  (@goodrecs,"@info:-:$uid $pid $date @info"); 
              }
          }#else
      }#if colselect
    }#foreach

    #split off the sort element and display the records    
    foreach (sort sort_criteria (@goodrecs)){
      next if (/^$/);
      $rec=(split(":-:",$_))[-1];
      if ($usefilter eq "none") {
        $lwproclist->insert('end', " $rec");
        }else {
          if ($rec =~/$filterstring/) {
          $lwproclist->insert('end', " $rec");
          }
          }
      }
    $currprocs=$#goodrecs;
} 

#perform the kill on each selected process
sub sel_nuke_proc {
 if (!@killlist[0]) {
  $confirmtext="
  No Processes Have Been Added To The Kill List!!
  
  Double-Clicking On One Process or Drag Selecting
  Multiple Processes and Right-Clicking Will Add 
  The Selected Process(es) To The Kill List..
  
  Double-Clicking On A Process In the Kill List 
  Will Remove That Process From The Kill List..";
  
  &oper_confirm("OK",0);
  return;
 }
 $confirmtext="Are You Sure??";
 &oper_confirm;
 return unless ($confirm eq "Yes");
  $select=();
  @statarray=();
  @pidarray=();
  $ks->configure(-foreground=>'#700000');  
  $ks->update;
  foreach (@killlist) {
    ($killpid)=(split(" ", $_ ))[1];
    if ($killpid ne "") { 
      $killstat="Killing $killpid";
      $ks->update;
      kill (9,$killpid);
      push (@pidarray,"$killpid");
      }#if killpid
      }#foreach @killlist
    $killstat="Refreshing..";
    $ks->update;
    $bottproclist->delete(0,'end');
    @killlist="";
    #give a change for the process table to update, otherwise there will be some 
    #occasional processes found to be still alive when actually they have been killed
    sleep(1);
    &populate_list($sortval,'none');
    foreach $pidcheck (@pidarray) {
      foreach $grec (@goodrecs) {
        $trimrec=(split(":-:",$grec))[1];
        $pidcheck2=(split(" ",$trimrec))[1];
        $defuncheck=(split(/\ +/,$trimrec))[-1];
        #print "defuncheck ($defuncheck)";
        #if the process is defunct, move on
        next if ($defuncheck=~/^<def/);
        if ("$pidcheck" eq "$pidcheck2") {
          push (@statarray,"Failed: $trimrec");
          }#if pid is found
        }#foreach goodrecs
      }#foreach $pidcheck
    if ($#statarray >-1) {
      &error_box(@statarray);
      }
    $selprocs=0;
    $killstat="Ready.."; 
    $ks->configure(-foreground=>'#004500');
    $ks->update; 
}#sub sel_list

#display any errors
sub error_box {
  (@errorlist)=@_;
  $errbox->destroy if Exists($errbox);
  #The main error window
  $errbox=new MainWindow;

  #The top frame for the text
  $errorframe1=$errbox->Frame(
    -borderwidth=>'0',
    -relief=>'flat',
    -background=>$background,
    )->pack(
      -expand=>1,
      -fill=>'both',
      );

  $errorframe2=$errbox->Frame(
    -borderwidth=>'0',
    -relief=>'flat',
    -background=>$background,
    )->pack(
      -fill=>'x',
      );

  # Create a scrollbar on the right side and bottom of the listbox
  $scroll=$errorframe1->Scrollbar(
    -orient=>'vert',
    -elementborderwidth=>1,
    -highlightthickness=>0,
    -background=>$background,
    -troughcolor=>$trbgd,
    -relief=>'flat',
    )->pack(
      -side=>'right',
      -fill =>'y',
      );

  $scrollhoriz=$errorframe1->Scrollbar(
    -orient=>'horiz',
    -elementborderwidth=>1,
    -highlightthickness=>0,
    -background=>$background,
    -troughcolor=>$trbgd,
    -relief=>'flat',
    )->pack(
      -side=>'bottom',
      -fill=>'x',
      );

  $errorwin=$errorframe1->ROText(
    -yscrollcommand => ['set', $scroll],
    -xscrollcommand => ['set', $scrollhoriz],
    -font=>'8x13bold',
    -relief => 'sunken',
    -highlightthickness=>0,
    -foreground=>'#900000',
    -background=>$txtbackground,
    -highlightcolor=>'blue',
    -borderwidth=>1, 
    -width=>90,
    -height=>10,
    -setgrid=>1,
    -wrap=>'none',
    )->pack(
      -expand=>1,
      -fill=>'both',
      );

  $scroll->configure(-command => ['yview', $errorwin]);
  $scrollhoriz->configure(-command => ['xview', $errorwin]);  
  $errorframe2->Button(
    -text=>'Ok',
    -borderwidth=>'1',
    -width=>'10',
    -background=>$buttonbackground,
    -foreground=>$txtforeground,
    -highlightthickness=>0,
    -font=>'8x13bold',
    -command=>sub{$errbox->destroy;}
      )->pack(
        -expand=>0,
        -side=>'bottom',
        -padx=>2,
        );    
 foreach (@errorlist){
   $errorwin->insert('end',"$_\n");
   }
   
 $errorcount=$#errorlist+1;
 $errbox->configure(-title=>"$errorcount Failures");  
}#sub error_box

#confirmation box before any actions are executed on the processes
sub oper_confirm {
  (@buttons)=@_;
  if (!@buttons) {
    @buttons=("Yes","Cancel",1);
    }
  #set the default button to the element number of the buttons array
  #and pop it off of the array so we dont create a button for it
  $defbutt=(@buttons[pop(@buttons)]);

  $confirmwin=new MainWindow;
  $confirmwin->withdraw;
  $confirmbox=$confirmwin->Dialog(
    -title=>"Message",
    -text=>$confirmtext,
    -borderwidth=>'1',
    -bg=>$background, #switched to -bg
    -fg=>'black', #-foreground doesnt work
    -highlightthickness=>0,
    -font=>'8x13bold',
    -bitmap=>'questhead',
    -default_button=>$defbutt,
    -buttons=>[@buttons],
    -wraplength =>'6i',
    );
  #the global option does a grab
  #$confirm=$confirmbox->Show(-global);    
  $confirm=$confirmbox->Show();
  return $confirm
}

sub get_selection {
  $selecttext="";
  #check the top widget for selection
  $test=($lwproclist->curselection);
  if ("$test" ne "") {
    $selecttext =($lwproclist->get($test));
    }
  $test=($bottproclist->curselection);
  if ("$test" ne "") {    
    $selecttext = $bottproclist->get($test);
    }
  #if any selection was retrieved, return it
  return $selecttext;
}#sub

sub clear_kills {
  $bottproclist->delete(0,'end');
  @killlist=();
  #count the slected processes  
  $selprocs=(@killlist);
}

#allow for multiple selection based on filters
sub multi_select {
  $Last="";
  ($select_key)=@_;
  $selecttext=&get_selection;
  if ($selecttext) { 

    if ($select_key eq "uid") {
      ($key)=(substr($selecttext,1,9));
      $key=~ s/ +$//;
      foreach (@goodrecs) {
        if (/:-:$key/) {
          $rec=(split(":-:",$_))[-1];
          push (@killlist,"$rec");    
          }#if 
          }#foreach
      }#if $select eqs uid

    if ($select_key eq "date") {
      ($key)=(substr($selecttext,19,10));
      $key=~ s/ +$//;
      foreach (@goodrecs) {
        $rec=(split(":-:",$_))[-1];
        ($key2)=(substr($rec,18,10));
        #remove spaces at the end
        $key2=~ s/ +$//;
        if ("$key" eq "$key2") {
          push (@killlist,"$rec");    
          }#if 
          }#foreach
      }#if $select eqs uid

    if ($select_key eq "info") {
      $eos=(length($selecttext)-29);
      ($key)=(substr($selecttext,29,$eos));
      #remove any trailing spaces
      $key=~ s/ +$//;
      foreach (@goodrecs) {
        if (/$key$/) {
          $rec=(split(":-:",$_))[-1];
          push (@killlist,"$rec");    
          }#if 
          }#foreach
      }#if $select eqs uid
    #remove any duplicates
    @killlist=grep(($Last eq $_ ? 0 : ($Last = $_, 1)),sort @killlist);
    $bottproclist->delete(0,'end');
    foreach (sort(@killlist)) {
      if ("$_" ne "") {
        $bottproclist->insert('end'," $_");
        }#if
      }#foreach
      #count the slected processes  
      $selprocs=(@killlist); 
      }#if $selecttext  
}#sub

#get the processes, logins etc..
sub whois_it {
  $selectext=&get_selection;
  if ($selecttext) {    
    ($userlogin,@info)=split(" ",$selecttext);
    (@fingertext)=`finger -s $userlogin`;
    $proccount=0;
    foreach (@goodrecs){
      if (/:-:$userlogin/) {
        $proccount++;
        }
      }#foreach
    
    $infowin->destroy if Exists($infowin);
    $infowin=new MainWindow;   
    $infowin->maxsize(745,183);
    $infowin->minsize(745,183); 
    $topwin=$infowin->Frame(
      -background=>$background,
      -highlightthickness=>0,   
      )->pack(
        -expand=>1,
        -fill=>'both',
        );
    
    $botwin=$infowin->Frame(
      -background=>$background,
      -highlightthickness=>0,       
      )->pack(
        -expand=>0,
        -fill=>'x',
        );

    # Create a scrollbar on the right side and bottom of the listbox
    $vscroll=$topwin->Scrollbar(
      -orient=>'vert',
      -elementborderwidth=>1,
      -highlightthickness=>0,
      -background=>$background,
      -troughcolor=>$trbgd,
      -relief=>'flat',
      )->pack(
        -side=>'right',
        -fill =>'y',
        );

    $toptext=$topwin->ROText(
      -yscrollcommand => ['set', $vscroll],
      -borderwidth=>'1',
      -height=>12,
      -width=>90,
      -font=>'8x13bold',
      -background=>$txtbackground,
      -foreground=>$txtforeground,
      -highlightthickness=>0,
        )->pack(
          -expand=>1,
          -padx=>2,
          -fill=>'both',
          );
        
    $vscroll->configure(-command => ['yview', $toptext]);
    
    #Dont like the alignment of the header generated from finger ... producing my own
    shift(@fingertext);
    $toptext->insert('end',"     Login      Name                TTY        Idle   When        Where\n");         
    $fingercount=0;
    foreach (@fingertext) {
      chop;
      $fingercount++;
      $fingercount=sprintf("% 3d",$fingercount);
      $toptext->insert('end',"$fingercount $_\n");      
      }

      $botwin->Button(
      -text=>'Ok',
      -borderwidth=>'1',
      -width=>'10',
      -background=>$buttonbackground,
      -foreground=>$txtforeground,
      -highlightthickness=>0,
      -font=>'8x13bold',
      -command=>sub{$infowin->destroy;}
        )->pack(
          -expand=>0,
          -side=>'bottom',
          -padx=>2,
          );   
    $titletext="User: $userlogin      Logins: $fingercount      Processes: $proccount";      
    $infowin->configure(-title=>$titletext);
    }#if selecttext
}#sub


#push the double clicked process info onto the kill array and listbox.
sub pushkill {
  @selecttext=$lwproclist->curselection;
  foreach (@selecttext) {
    $selecttext=$lwproclist->get($_);
    $Last="";
    $selecttext=~ s/^ +//;
    push (@killlist,"$selecttext");
    }
  #remove any duplicates 
  @killlist=grep(($Last eq $_ ? 0 : ($Last = $_, 1)),sort @killlist);
  #clear the kill proc list and replace it
  $bottproclist->delete('0','end');
  foreach (sort(@killlist)) {
    if ("$_" ne "") { 
      $bottproclist->insert('end'," $_");
      }#if
    }#foreach 
  #count the slected processes  
  $selprocs=(@killlist);
}#sub

#pop the double clicked process info of of the kill array and listbox
sub popkill {
  $select=($bottproclist->curselection);
  if ($select) {
    splice(@killlist,$select,1);
    }
  #special handling for the first element of the array
  if ($select==0) {
    splice(@killlist,0,1);
    } 
  $selprocs=(@killlist);
  $bottproclist->delete('0','end');
  foreach (@killlist) {
    if ("$_" ne "") { 
      $bottproclist->insert('end'," $_");
      }#if $_
      }#foreach
  $bottproclist->selection('set',$select-1);
  $bottproclist->activate($select-1);
  $bottproclist->see($select-1);
  }#sub


#filter the display based on a string entered 
sub filter_win {
  $filterbutton->configure(-state=>'normal');
  
  $SW->destroy if Exists($SW);
  $SW=new MainWindow;
  $SW->configure(-title=>'Process List Filter');
  #width,height in pixels    
  $SW->minsize(424,51);
  $SW->maxsize(724,51);
  
  $newfilter=1;
  #The top frame for the text
  $filterframe1=$SW->Frame(
    -borderwidth=>'0',
    -relief=>'flat',
    -background=>$background,
    )->pack(
      -expand=>1,
      -fill=>'both',
      );
 
  $filterframe2=$SW->Frame(
    -borderwidth=>'1',
    -relief=>'sunken',
    -background=>$background,
    )->pack(
      -fill=>'x',
      -pady=>0,
      );

  $ssentry=$filterframe1->Label(
    -relief=>'flat',
    -text=>'String:',
    -highlightthickness=>0,
    -background=>$background,
    -foreground=>$txtforeground,
    -borderwidth=>0,
    -width=>12,
    -bg=> 'white',
    -font=>$winfont,
    )->pack(
      -side=>'left',
      -fill=>'x',
      -expand=>0,
      );

  $ssentry=$filterframe1->ComboEntry(
    -font=>$winfont,
    -listfont=>$winfont,
    -relief=>'sunken',
    -textvariable=>\$filterstring,
    -highlightthickness=>1,
    -highlightcolor=>'black',
    -highlightbackground=>$background,
    -bg=>$background,
    -foreground=>$txtforeground,
    -borderwidth=>1,
    -width=>12,
    -showmenu=> 1,
    -bg=> 'white',
    -invoke=>sub{
      $ssentry->focus;
      #cant decide if I want to automatically filter when an element is selected
      #from the list or not
      #&filter_it;
      },
    )->pack(
      -fill=>'both',
      -expand=>0,
      -pady=>4,
      );


  $filterframe2->Radiobutton(
    -text=>'Login',
    -variable=>\$sortval,
    -value=>0,
    -borderwidth=>'1',
    -width=>5,
    -background=>$background,
    -foreground=>$txtforeground,
    -highlightthickness=>0,
    -activebackground=>$background,
    -font=>$winfont,
    )->pack(
        -side=>'left',
        -padx=>0,
        );

  $filterframe2->Radiobutton(
    -text=>'PID',
    -variable=>\$sortval,
    -value=>1,
    -borderwidth=>'1',
    -width=>5,
    -background=>$background,
    -foreground=>$txtforeground,
    -highlightthickness=>0,
    -activebackground=>$background,
    -font=>$winfont,
    )->pack(
        -side=>'left',
        -padx=>0,
        );
    $filterframe2->Radiobutton(
    -text=>'Date',
    -variable=>\$sortval,
    -value=>2,
    -borderwidth=>'1',
    -width=>5,
    -background=>$background,
    -foreground=>$txtforeground,
    -highlightthickness=>0,
    -activebackground=>$background,
    -font=>$winfont,
    )->pack(
        -side=>'left',
        -padx=>0,
        );
    $filterframe2->Radiobutton(
    -text=>'Info',
    -variable=>\$sortval,
    -value=>3,
    -borderwidth=>'1',
    -width=>5,
    -background=>$background,
    -foreground=>$txtforeground,
    -highlightthickness=>0,
    -activebackground=>$background,
    -font=>$winfont,
    )->pack(
        -side=>'left',
        -padx=>0,
        );
    
  $filterframe2->Button(
    -text=>'Cancel',
    -borderwidth=>'1',
    -width=>6,
    -background=>$buttonbackground,
    -foreground=>$txtforeground,
    -highlightthickness=>0,
    -font=>$winfont,
    -command=>sub{$SW->destroy;}
      )->pack(
        -side=>'right',
        -padx=>2,
        );

  $filterframe2->Button(
    -text=>'Filter',
    -borderwidth=>'1',
    -width=>6,
    -background=>$buttonbackground,
    -foreground=>$txtforeground,
    -highlightthickness=>0,
    -font=>$winfont,
    -command=>sub {&filter_it;},
    )->pack(
        -side=>'right',
        -padx=>2,
        );

        
  #press enter and perform a single find
  $ssentry->bind('<KeyPress-Return>'=>sub{&filter_it;});
  $ssentry->focus;     
} # sub filter

sub filter_it {
  return if ($filterstring eq "");
  &populate_list($sortval,'usefilter');
  $Last="";
  push (@filterlist, $filterstring);
  #a method to ensure no duplicates are stored in the array
  @filterlist=grep(($Last eq $_ ? 0 : ($Last = $_, 1)),sort @filterlist);
  $ssentry->configure(-list=>[(@filterlist)],);
  $ssentry->focus;
}

#return a positive status 
1;
