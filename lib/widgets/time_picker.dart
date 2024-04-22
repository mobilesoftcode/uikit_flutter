import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  final bool roundBorder;
  final double maxWidth;
  final double maxHeight;
  final Color colorBackground;
  final Color colorSelected;
  final Color colorBtnClose;
  final DateTime? initialTime; 
  final Function(DateTime) onTimeSelected;
  final Function() onClose;

  const TimePicker({
    super.key,  
    this.roundBorder = false,
    this.maxWidth = 250,
    this.maxHeight = 200,
    this.colorBackground = Colors.transparent,
    this.colorSelected = Colors.black,
    this.colorBtnClose = Colors.black, 
    this.initialTime,
    required this.onTimeSelected,
    required this.onClose,
  });

  @override
  State<TimePicker> createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  int hours = 24;
  int minutes = 60;
  late int hourSelected;
  late int minuteSelected;
  late DateTime initialTine; 

  @override
  void initState() {   
    super.initState();
    hourSelected = 0;
    minuteSelected = 0;
    initialTine = widget.initialTime ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    Color colorBackground = widget.colorBackground == Colors.transparent
    ? widget.colorBackground
    : widget.colorBackground.withOpacity(0.2); // Sfondo semitrasparente

    return Container(
      decoration: widget.roundBorder
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Imposta il raggio di curvatura dei bordi
            color: colorBackground,  
          )
        : BoxDecoration( 
          color: colorBackground, 
        ),
      child: ConstrainedBox( 
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,  
          maxHeight: widget.maxHeight,  
        ),
         
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children:[
              _ListWhellScrollViewDigits( // scrollview ore
                colorSelected: widget.colorSelected,  
                itemCount: hours, 
                initialValue: initialTine.hour,
                onDigitSelected: (value){
                  setState(() {
                    hourSelected = value; 
                    widget.onTimeSelected(
                      //Restituisce ora selezionata   
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hourSelected, minuteSelected)
                    );
                  });             
                }
              ),
            
              const _ListWheelSeparator(),  // separatore
                              
              _ListWhellScrollViewDigits(   // scrollview minuti
                colorSelected: widget.colorSelected,  
                itemCount: minutes, 
                initialValue: initialTine.minute,
                onDigitSelected: (value){
                  setState(() {
                    minuteSelected = value; 
                    widget.onTimeSelected(
                       //Restituisce ora selezionata   
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hourSelected, minuteSelected)
                    );
                  });                     
                }        
              ),
              
              _ShowClose(
                colorBtnClose: widget.colorBtnClose,
                onClose: (){
                  widget.onClose();
                },
              ),
            ],
          ),
        ),
      ),
    );
  } 
}

//  COMPONENTE CON BOTTONE CHIUDI 
class _ShowClose extends StatelessWidget {
  const _ShowClose({
    required this.colorBtnClose,
    required this.onClose,
  });

  final Color colorBtnClose;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextStyle(
      color: colorBtnClose, 
      fontSize: 12, 
      fontWeight: FontWeight.bold
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Spacer(), 
        TextButton(
          onPressed: () {
            onClose();  
          },
          child: Text(
            style : buttonStyle,
            'Chiudi'
            ),
        ),
      ],
    );
  }
}

// COMPONENTE SEPARATORE 
class _ListWheelSeparator extends StatelessWidget {
  const _ListWheelSeparator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          Text (
            ":",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}

// COMPONENTE SCROLLVIEW
class _ListWhellScrollViewDigits extends StatefulWidget {
  final int initialValue;
  final Color colorSelected;
  final int itemCount;
  final ValueChanged<int> onDigitSelected;

  const _ListWhellScrollViewDigits({
    this.initialValue = 0,
    required this.colorSelected,
    required this.itemCount,
    required this.onDigitSelected
  });

  @override
  State<_ListWhellScrollViewDigits> createState() => _ListWhellScrollViewDigitsState();
}

class _ListWhellScrollViewDigitsState extends State<_ListWhellScrollViewDigits> {
  late int digitSelected;
  late FixedExtentScrollController controller ;
  
  @override
  void initState() {
    super.initState();
    digitSelected = widget.initialValue;
    controller = FixedExtentScrollController(initialItem: widget.initialValue);  // Valore iniziale selezionato
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleSelectedItemChanged(widget.initialValue); // Chiama manualmente il gestore onSelectedItemChanged
    });
  }
  
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _handleSelectedItemChanged(int index) {
     widget.onDigitSelected(index);
     digitSelected = index;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListWheelScrollView(
        controller: controller,
        offAxisFraction: 0, //inclinazione dx
        diameterRatio: 2,
        itemExtent: 25, // dim item
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged:(index) {
          _handleSelectedItemChanged(index);
        },
        children: _listWheelChildren(widget.colorSelected, widget.itemCount, digitSelected)
      ),
    );
  }

// LISTA ELEMENTI SCROLLVIEW
List <Widget> _listWheelChildren(Color colorSelected, int numChild, int digitSelected) {
    return List.generate(numChild, (index) {
      return  _HoursDigit(colorSelected : colorSelected,index: index, digitSelected: digitSelected);        
    });
  }
}

// ELEMENTO SCROLLVIEW
class _HoursDigit extends StatelessWidget {
  const _HoursDigit({
    required this.colorSelected,
    required this.index,
    required this.digitSelected
  });

  final Color colorSelected;
  final int index;
  final int digitSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == digitSelected;
  
    final textStyle = TextStyle(
      color: isSelected ? colorSelected: Colors.black, 
      fontSize: isSelected ? 16 : 12,
      fontWeight: isSelected ?FontWeight.bold : FontWeight.normal
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: index == digitSelected
              ? const BorderSide(color: Colors.black)
              : BorderSide.none,
          bottom: index == digitSelected
              ? const BorderSide(color: Colors.black)
              : BorderSide.none,
        ),
      ),
      child: Text(
        index.toString().padLeft(2, '0'),
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}
