import 'package:bruno/src/components/picker/base/brn_picker_title_config.dart';
import 'package:bruno/src/components/picker/time_picker/brn_date_time_formatter.dart';
import 'package:bruno/src/components/picker/time_picker/date_picker/brn_date_widget.dart';
import 'package:bruno/src/components/selection/bean/brn_selection_common_entity.dart';
import 'package:bruno/src/components/selection/controller/brn_selection_view_date_picker_controller.dart';
import 'package:bruno/src/components/selection/widget/brn_selection_datepicker_animate_widget.dart';
import 'package:bruno/src/theme/configs/brn_selection_config.dart';
import 'package:bruno/src/utils/brn_tools.dart';
import 'package:bruno/src/utils/i18n/brn_date_picker_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void OnRangeChangedFunction(String minInput, String maxInput);
typedef void OnTappedFunction();

// ignore: must_be_immutable
class BrnSelectionDateRangeItemWidget extends StatefulWidget {
  final BrnSelectionEntity item;

  /// 选中色
  final Color confirmColor;

  /// 背景色
  final Color backgroundColor;

  /// 输入框显示文字大小
  final double showTextSize;

  final bool isShouldClearText;

  /// 是否需要标题
  final bool isNeedTitle;

  /// 日期格式
  final String dateFormat;

  final TextEditingController minTextEditingController;
  final TextEditingController maxTextEditingController;

  final OnTappedFunction onTapped;

  BrnSelectionConfig themeData;

  BrnSelectionDateRangeItemWidget(
      {this.item,
      @required this.minTextEditingController,
      @required this.maxTextEditingController,
      this.confirmColor,
      this.backgroundColor = Colors.white,
      this.isShouldClearText = false,
      this.isNeedTitle = true,
      this.showTextSize = 16,
      this.dateFormat,
      this.onTapped,
      this.themeData});

  _BrnSelectionDateRangeItemWidgetState createState() =>
      _BrnSelectionDateRangeItemWidgetState();
}

class _BrnSelectionDateRangeItemWidgetState
    extends State<BrnSelectionDateRangeItemWidget> {
  BrnSelectionDatePickerController _datePickerController =
      BrnSelectionDatePickerController();

  @override
  void initState() {
    var minDateTime;
    if (widget.item.customMap != null && widget.item.customMap['min'] != null) {
      minDateTime = DateTimeFormatter.convertIntValueToDateTime(
          widget.item?.customMap['min']);
    }
    var maxDateTime;
    if (widget.item.customMap != null && widget.item.customMap['max'] != null) {
      maxDateTime = DateTimeFormatter.convertIntValueToDateTime(
          widget.item?.customMap['max']);
    }
    widget.minTextEditingController.text = minDateTime != null
        ? DateTimeFormatter.formatDate(minDateTime,
            widget.dateFormat ?? 'yyyy年MM月dd日', DateTimePickerLocale.zh_cn)
        : '';
    widget.maxTextEditingController.text = maxDateTime != null
        ? DateTimeFormatter.formatDate(maxDateTime,
            widget.dateFormat ?? 'yyyy年MM月dd日', DateTimePickerLocale.zh_cn)
        : '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: widget.backgroundColor,
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          children: <Widget>[
            widget.isNeedTitle
                ? Container(
                    margin: EdgeInsets.only(bottom: 5),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.item.title != null ? widget.item.title : '自定义区间',
                      textAlign: TextAlign.left,
                      style: widget.themeData.rangeTitleTextStyle
                          ?.generateTextStyle(),
                    ),
                  )
                : Container(),
            Row(
              children: <Widget>[
                getDateRangeTextField(false),
                Container(
                  child: Text(
                    "至",
                    style: widget.themeData.inputTextStyle?.generateTextStyle(),
                  ),
                ),
                getDateRangeTextField(true),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getDateRangeTextField(bool isMax) {
    return Expanded(
      child: TextField(
        enableInteractiveSelection: false,
        readOnly: true,
        onTap: () {
          widget.onTapped();
          onTextTapped(isMax);
        },
        style: widget.themeData.inputTextStyle?.generateTextStyle(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.numberWithOptions(),
        onChanged: (input) {
          widget.item.isSelected = true;
        },
        controller: isMax
            ? widget.maxTextEditingController
            : widget.minTextEditingController,
        cursorColor: widget.themeData.commonConfig.brandPrimary,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintStyle: widget.themeData.hintTextStyle?.generateTextStyle(),
          hintText: (!isMax ? '开始日期' : '结束日期'),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            width: 1,
            color: widget.themeData.commonConfig.borderColorBase,
          )),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            width: 1,
            color: widget.themeData.commonConfig.borderColorBase,
          )),
          contentPadding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  void onTextTapped(bool isMax) {
    if (_datePickerController?.isShow ?? false) return;
    String format = 'yyyy年,MM月,dd日';
    DateTime minDate = DateTimeFormatter.convertIntValueToDateTime(
        (widget.item?.extMap ?? Map())['min']);
    DateTime maxDate = DateTimeFormatter.convertIntValueToDateTime(
        (widget.item?.extMap ?? Map())['max']);

    DateTime minSelectedDateTime = BrunoTools.isEmpty(widget.item?.customMap)
        ? null
        : DateTimeFormatter.convertIntValueToDateTime(
            widget.item?.customMap['min']);
    DateTime maxSelectedDateTime = BrunoTools.isEmpty(widget.item?.customMap)
        ? null
        : DateTimeFormatter.convertIntValueToDateTime(
            widget.item?.customMap['max']);

    DateTime _minDateTime;
    DateTime _maxDateTime;
    if (widget.item?.customMap == null ||
        (widget.item?.customMap['min'] == null &&
            widget.item?.customMap['max'] == null)) {
      // 如果开始时间和结束时间均未选择
      _minDateTime = minDate;
      _maxDateTime = maxDate;
    } else {
      _minDateTime = !isMax ? minDate : (minSelectedDateTime ?? minDate);
      _maxDateTime = isMax ? maxDate : (maxSelectedDateTime ?? maxDate);
    }

    Widget content = BrnDateWidget(
      canPop: false,
      minDateTime: _minDateTime,
      maxDateTime: _maxDateTime,
      initialDateTime: isMax ? maxSelectedDateTime : minSelectedDateTime,
      dateFormat: format,
      pickerTitleConfig: BrnPickerTitleConfig(
          showTitle: true,
          // UI 规范规定高度按照比例设置，UI稿的比利为 240 / 812
          titleContent: isMax ? '请选择结束时间' : '请选择开始时间'),
      onCancel: () {
        closeSelectionPopupWindow();
      },
      onConfirm: (DateTime selectedDate, List<int> selectedIndex) {
        widget.item.isSelected = true;
        String selectedDateStr = DateTimeFormatter.formatDate(selectedDate,
            widget.dateFormat ?? 'yyyy年MM月dd日', DateTimePickerLocale.zh_cn);
        if (isMax) {
          widget.maxTextEditingController.text = selectedDateStr;
        } else {
          widget.minTextEditingController.text = selectedDateStr;
        }
        if (widget.item.customMap == null) {
          widget.item.customMap = {};
        }
        widget.item.customMap[isMax ? 'max' : 'min'] =
            selectedDate.millisecondsSinceEpoch.toString();
        closeSelectionPopupWindow();

        if (!isMax &&
            BrunoTools.isEmpty(widget.maxTextEditingController.text)) {
          onTextTapped(true);
        }
        setState(() {});
      },
    );
    _datePickerController.screenHeight = MediaQuery.of(context).size.height;
    _createDatePickerEntry(context, content);
    Overlay.of(context).insert(_datePickerController.entry);
    _datePickerController.show();
  }

  void _createDatePickerEntry(BuildContext context, Widget content) {
    OverlayEntry entry = OverlayEntry(builder: (context) {
      return GestureDetector(
        onTap: () {
          closeSelectionPopupWindow();
        },
//        onVerticalDragStart: (_) {
//          closeSelectionPopupWindow();
//        },
//        onHorizontalDragStart: (_) {
//          closeSelectionPopupWindow();
//        },
        child: Container(
          color: Color(0xB3000000),
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.bottomCenter,
          child: BrnSelectionDatePickerAnimationWidget(
              controller: _datePickerController, view: content),
        ),
      );
    });

    _datePickerController.entry = entry;
  }

  void closeSelectionPopupWindow() {
    if (_datePickerController?.isShow ?? false) {
      _datePickerController?.isShow = false;
      _datePickerController?.hide();
      _datePickerController?.entry?.remove();
      _datePickerController?.entry = null;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _datePickerController?.isShow = false;
    _datePickerController?.hide();
    _datePickerController?.entry?.remove();
    _datePickerController?.entry = null;
    super.dispose();
  }
}
