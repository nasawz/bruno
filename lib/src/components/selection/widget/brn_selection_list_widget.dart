import 'dart:math';

import 'package:bruno/src/components/button/brn_big_main_button.dart';
import 'package:bruno/src/components/selection/bean/brn_selection_common_entity.dart';
import 'package:bruno/src/components/selection/brn_selection_util.dart';
import 'package:bruno/src/components/selection/widget/brn_selection_menu_widget.dart';
import 'package:bruno/src/components/selection/widget/brn_selection_single_list_widget.dart';
import 'package:bruno/src/constants/brn_asset_constants.dart';
import 'package:bruno/src/theme/configs/brn_selection_config.dart';
import 'package:bruno/src/utils/brn_tools.dart';
import 'package:flutter/material.dart';

typedef void SingleListItemSelect(int listIndex, int index, BrnSelectionEntity entity);

typedef void ListBgClickFunction();

// ignore: must_be_immutable
class BrnListSelectionGroupWidget extends StatefulWidget {
  final BrnSelectionEntity entity;
  final double maxContentHeight;
  final bool showSelectedCount;
  final ListBgClickFunction bgClickFunction;
  final BrnOnRangeSelectionConfirm onSelectionConfirm;
  BrnSelectionConfig themeData;

  BrnListSelectionGroupWidget(
      {Key key,
      @required this.entity,
      this.maxContentHeight = DESIGN_SELECTION_HEIGHT,
      this.showSelectedCount = false,
      this.bgClickFunction,
      this.onSelectionConfirm,
      this.themeData})
      : super(key: key);

  @override
  _BrnSelectionGroupViewState createState() => _BrnSelectionGroupViewState();
}

class _BrnSelectionGroupViewState extends State<BrnListSelectionGroupWidget> {

  final int maxShowCount = 6;

  List<BrnSelectionEntity> _firstList = List();
  List<BrnSelectionEntity> _secondList = List();
  List<BrnSelectionEntity> _thirdList = List();
  List<BrnSelectionEntity> _originalSelectedItemsList = List();
  int _firstIndex;
  int _secondIndex;
  int _thirdIndex;

  int totalLevel = 0;

  bool _isConfirmClick = false;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    if (!_isConfirmClick) {
      _resetSelectionDatas(widget.entity);
      _restoreOriginalData();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    totalLevel = BrnSelectionUtil.getTotalLevel(widget.entity);
    return GestureDetector(
      onTap: () {
        _backgroundTap();
      },
      child: Container(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {},
            child: Column(
              children: _configWidgets(),
            ),
          )),
    );
  }

  //pragma mark -- config widgets

  List<Widget> _configWidgets() {
    List<Widget> widgetList = List();

    widgetList.add(_listWidget());
    // TODO 判断是否添加 Bottom
    if (_firstList != null) {
      if (totalLevel == 1 && widget.entity.filterType == BrnSelectionFilterType.Radio) {
      } else {
        widgetList.add(_bottomWidget());
      }
    }
    return widgetList;
  }

  Widget _listWidget() {
    List<Widget> widgets = List();

    if (!BrunoTools.isEmpty(_firstList) &&
        BrunoTools.isEmpty(_secondList) &&
        BrunoTools.isEmpty(_thirdList)) {
      /// 1、仅有一级的情况
      /// 1.1 一级单选 && 没有自定义范围的情况
      widgets.add(BrnSelectionSingleListWidget(
          items: _firstList,
          themeData: widget.themeData,
          backgroundColor: getBgByListIndex(1),
          selectedBackgroundColor: getSelectBgByListIndex(1),
          maxHeight: widget.maxContentHeight,
          flex: getFlexByListIndex(1),
          focusedIndex: _firstIndex,
          singleListItemSelect: (int listIndex, int index, BrnSelectionEntity entity) {
            _setFirstIndex(index);
            if (totalLevel == 1 && widget.entity.filterType == BrnSelectionFilterType.Radio) {
              _confirmButtonClickEvent();
            }
          }));
    } else if (!BrunoTools.isEmpty(_firstList) &&
        !BrunoTools.isEmpty(_secondList) &&
        BrunoTools.isEmpty(_thirdList)) {
      /// 2、有二级的情况
      widgets.add(BrnSelectionSingleListWidget(
          items: _firstList,
          themeData: widget.themeData,
          backgroundColor: getBgByListIndex(1),
          selectedBackgroundColor: getSelectBgByListIndex(1),
          flex: getFlexByListIndex(1),
          focusedIndex: _firstIndex,
          singleListItemSelect: (int listIndex, int index, BrnSelectionEntity entity) {
            _setFirstIndex(index);
          }));

      widgets.add(BrnSelectionSingleListWidget(
          items: _secondList,
          themeData: widget.themeData,
          backgroundColor: getBgByListIndex(2),
          selectedBackgroundColor: getSelectBgByListIndex(2),
          flex: getFlexByListIndex(2),
          focusedIndex: _secondIndex,
          singleListItemSelect: (int listIndex, int index, BrnSelectionEntity entity) {
            _setSecondIndex(index);
          }));
    } else if (!BrunoTools.isEmpty(_firstList) &&
        !BrunoTools.isEmpty(_secondList) &&
        !BrunoTools.isEmpty(_thirdList)) {
      /// 3、有三级的情况
      widgets.add(BrnSelectionSingleListWidget(
          items: _firstList,
          themeData: widget.themeData,
          backgroundColor: getBgByListIndex(1),
          selectedBackgroundColor: getSelectBgByListIndex(1),
          flex: getFlexByListIndex(1),
          focusedIndex: _firstIndex,
          singleListItemSelect: (int listIndex, int index, BrnSelectionEntity entity) {
            _setFirstIndex(index);
          }));

      widgets.add(BrnSelectionSingleListWidget(
          items: _secondList,
          themeData: widget.themeData,
          backgroundColor: getBgByListIndex(2),
          selectedBackgroundColor: getSelectBgByListIndex(2),
          flex: getFlexByListIndex(2),
          focusedIndex: _secondIndex,
          singleListItemSelect: (int listIndex, int index, BrnSelectionEntity entity) {
            _setSecondIndex(index);
          }));
      widgets.add(BrnSelectionSingleListWidget(
          items: _thirdList,
          themeData: widget.themeData,
          backgroundColor: getBgByListIndex(3),
          selectedBackgroundColor: getSelectBgByListIndex(3),
          flex: getFlexByListIndex(3),
          focusedIndex: _thirdIndex,
          singleListItemSelect: (int listIndex, int index, BrnSelectionEntity entity) {
            if (entity.isSelected) {
              _thirdIndex = index;
            } else {
              _thirdIndex = -1;
            }
            setState(() {});
          }));
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          color: Colors.white,
          constraints: BoxConstraints(maxHeight: widget.maxContentHeight),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: widgets,
          ),
        ),
        // 目前列表最大高度为 240，每个 Item 高度为 40。顾最大展示个数是 6，大于 6 则显示阴影。
        getMostListCount(widgets.length) > maxShowCount
            ? IgnorePointer(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white,
                      ],
                      stops: [0, 1.0],
                    ),
                  ),
                ),
              )
            : Container(
                height: 0,
                width: 0,
              )
      ],
    );
  }

  Widget _bottomWidget() {
    return Column(
      children: <Widget>[
        Divider(
          height: 0.3,
          color: widget.themeData.commonConfig.dividerColorBase,
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(8, 11, 20, 11),
          child: Row(
            children: <Widget>[
              InkWell(
                child: Container(
                  padding: EdgeInsets.only(left: 12, right: 20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 24,
                        width: 24,
                        child: BrunoTools.getAssetImage(BrnAsset.iconSelectionReset),
                      ),
                      Text(
                        "重置",
                        style: widget.themeData.resetTextStyle.generateTextStyle(),
                      )
                    ],
                  ),
                ),
                onTap: _clearAllSelectedItems,
              ),
              Expanded(
                child: BrnBigMainButton(
                  title: '确定',
                  onTap: () {
                    _confirmButtonClickEvent();
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  //pragma mark -- event responder

  void _confirmButtonClickEvent() {
    _isConfirmClick = true;

    /// 确认回调前 根据规则，统一处理筛选数据选择状态
    _processFilterDataOnConfirm();
    if (widget.onSelectionConfirm != null) {
      //更多和无tips等外部调用的多选需要传递此值selectedLastColumnArray
      widget.onSelectionConfirm(widget.entity, _firstIndex, _secondIndex, _thirdIndex);
    }
  }

  void _clearAllSelectedItems() {
    _resetSelectionDatas(widget.entity);
    setState(() {
      _configDefaultInitSelectIndex();
      _refreshDataSource();
    });
  }

  //pragma mark -- private methods

  // 初始化数据

  void _initData() {
    // 生成筛选节点树
    _originalSelectedItemsList = widget.entity.selectedList();
    for (BrnSelectionEntity entity in _originalSelectedItemsList) {
      entity.isSelected = true;
      if (entity.customMap != null) {
        entity.originalCustomMap = Map.from(entity.customMap);
      }
    }

    // 初始化每列的选中 index 为 -1，未选中。
    _configDefaultInitSelectIndex();
    // 遍历数据源，设置真正选中的index
    _configDefaultSelectedData();
    // 使用真正选中的index来刷新数组
    _refreshDataSource();
  }

  // 设置默认无选中项的时候默认选择index
  void _configDefaultInitSelectIndex() {
    _firstIndex = _secondIndex = _thirdIndex = -1;
  }

  // 刷新3个ListView的数据源
  void _refreshDataSource() {
    _firstList = widget.entity.children;
    if (_firstIndex >= 0 && _firstList.length > _firstIndex) {
      _secondList = _firstList[_firstIndex].children;
      if (_secondIndex >= 0 && _secondList.length > _secondIndex) {
        _thirdList = _secondList[_secondIndex].children;
      } else {
        _thirdList = null;
      }
    } else {
      _secondList = null;
      _thirdList = null;
    }
  }

  void _configDefaultSelectedData() {
    _firstList = widget.entity.children;
    //是否已选择的item里面有第一列的
    if (_firstList == null) {
      _secondIndex = -1;
      _secondList = null;

      _thirdIndex = -1;
      _thirdList = null;

      return;
    }
    _firstIndex = getInitialSelectIndex(_firstList);

    if (_firstIndex >= 0 && _firstIndex < _firstList.length) {
      _secondList = _firstList[_firstIndex].children;
      if (_secondList != null) {
        _secondIndex = getInitialSelectIndex(_secondList);
      }
    }

    if (_secondList == null) {
      _thirdIndex = -1;
      _thirdList = null;
      return;
    }
    if (_secondIndex >= 0 && _secondIndex < _secondList.length) {
      _thirdList = _secondList[_secondIndex].children;
      if (_thirdList != null) {
        _thirdIndex = getInitialSelectIndex(_thirdList);
      }
    }
  }

  ///还原数据选中状态
  void _resetSelectionDatas(BrnSelectionEntity entity) {
    entity.isSelected = false;
    entity.customMap = null;
    if (BrnSelectionFilterType.Range == entity.filterType) {
      entity.title = null;
    }
    if (entity.children != null) {
      for (BrnSelectionEntity subEntity in entity.children) {
        _resetSelectionDatas(subEntity);
      }
    }
  }

  ///数据还原
  void _restoreOriginalData() {
    for (BrnSelectionEntity commonEntity in _originalSelectedItemsList) {
      commonEntity.isSelected = true;
      if (commonEntity.originalCustomMap != null) {
        commonEntity.customMap = Map.from(commonEntity.originalCustomMap);
      }
    }
  }

  //pragma mark -- getter and setter

  void _setFirstIndex(int firstIndex) {
    _firstIndex = firstIndex;
    _secondIndex = -1;
    if (widget.entity.children.length > _firstIndex) {
      List<BrnSelectionEntity> seconds = widget.entity.children[_firstIndex].children;
      if (seconds != null) {
        _secondIndex = getInitialSelectIndex(seconds);

        if (_secondIndex >= 0) {
          _setSecondIndex(_secondIndex);
        }
      }
    }
    setState(() {
      _refreshDataSource();
    });
  }

  void _setSecondIndex(int secondIndex) {
    _secondIndex = secondIndex;
    _thirdIndex = -1;
    List<BrnSelectionEntity> seconds = widget.entity.children[_firstIndex].children;
    if (seconds.length > _secondIndex) {
      List<BrnSelectionEntity> thirds = seconds[_secondIndex].children;
      if (thirds != null) {
        _thirdIndex = getInitialSelectIndex(thirds);
      }
    }
    setState(() {
      _refreshDataSource();
    });
  }

  int getInitialSelectIndex(List<BrnSelectionEntity> levelList) {
    int index = -1;
    if (levelList == null || levelList.length == 0) {
      return index;
    }

    for (BrnSelectionEntity entity in levelList) {
      if (entity.isSelected) {
        index = levelList.indexOf(entity);
        break;
      }
    }

    /// 非跨区域选择时，走此方法设置默认选择 index
    if (index < 0) {
      for (BrnSelectionEntity entity in levelList) {
        if (entity.isUnLimit() &&
            BrnSelectionUtil.getTotalLevel(entity) > 1 &&
            !entity.parent.hasCheckBoxBrother()) {
          index = levelList.indexOf(entity);
          break;
        }
      }
    }
    return index;
  }

  /// 默认占比为 1，
  /// 其中一列、两列情况下，占比都是 1
  /// 当为三列数据时，占比随着 listIndex 增加而增大。为 3：3：4 比例水平占据屏幕
  int getFlexByListIndex(int listIndex) {
    int flex = 1;
    if (totalLevel == 1 || totalLevel == 2) {
      flex = 1;
    } else if (totalLevel == 3) {
      if (listIndex == 1) {
        flex = 3;
      } else if (listIndex == 2) {
        if (_thirdList == null) {
          flex = 7;
        } else {
          flex = 3;
        }
      } else if (listIndex == 3) {
        flex = 4;
      }
    }
    return flex;
  }

  Color getSelectBgByListIndex(int listIndex) {
    Color deepSelectBgColor = widget.themeData.deepSelectBgColor;
    Color middleSelectBgColor = widget.themeData.middleSelectBgColor;
    Color lightSelectBgColor = widget.themeData.lightSelectBgColor;
    if (totalLevel == 1) {
      return lightSelectBgColor;
    } else if (totalLevel == 2) {
      if (listIndex == 1) {
        return middleSelectBgColor;
      } else {
        return lightSelectBgColor;
      }
    } else {
      if (listIndex == 1) {
        return deepSelectBgColor;
      } else if (listIndex == 2) {
        return middleSelectBgColor;
      } else if (listIndex == 3) {
        return lightSelectBgColor;
      }
    }
    return lightSelectBgColor;
  }

  Color getBgByListIndex(int listIndex) {
    Color deepNormalBgColor = widget.themeData.deepNormalBgColor;
    Color middleNormalBgColor = widget.themeData.middleNormalBgColor;
    Color lightNormalBgColor = widget.themeData.lightNormalBgColor;
    if (totalLevel == 1) {
      return lightNormalBgColor;
    } else if (totalLevel == 2) {
      if (listIndex == 1) {
        return middleNormalBgColor;
      } else {
        return lightNormalBgColor;
      }
    } else {
      if (listIndex == 1) {
        return deepNormalBgColor;
      } else if (listIndex == 2) {
        return middleNormalBgColor;
      } else if (listIndex == 3) {
        return lightNormalBgColor;
      }
    }
    return lightNormalBgColor;
  }

  void _backgroundTap() {
    //还原数据：内部先将最新的状态清空，然后数据还原。
    _resetSelectStatus();
    if (widget.bgClickFunction != null) {
      //执行回调
      widget.bgClickFunction();
    }
  }

  void _resetSelectStatus() {
    _clearAllSelectedItems();
    //数据还原
    for (BrnSelectionEntity commonEntity in _originalSelectedItemsList) {
      commonEntity.isSelected = true;
      if (commonEntity.originalCustomMap != null) {
        commonEntity.customMap = Map.from(commonEntity.originalCustomMap);
      }
    }
  }

  /// 提交前对筛选数据做进一步处理，
  /// !!! 只有子筛选项存在被选中的 Item 才可以被设置为 true。
  void _processFilterDataOnConfirm() {
    if (widget.entity?.children != null) {
      _processSelectedStatus(widget.entity);
    }
  }

  _processSelectedStatus(BrnSelectionEntity entity) {
    if (entity != null && entity.children != null && entity.children.length > 0) {
      entity.children.forEach((f) => _processSelectedStatus(f));
      if (entity.hasCheckBoxBrother()) {
        entity.isSelected = entity.children.where((_) => _.isSelected).length > 0;
      }
    }
  }

  int getMostListCount(int length) {
    int mostCount = 0;
    if (length == 1) {
      mostCount = _firstList?.length ?? 0;
    } else if (length == 2) {
      int firstCount = _firstList?.length ?? 0;
      int secondCount = _secondList?.length ?? 0;
      mostCount = max(firstCount, secondCount);
    } else if (length == 3) {
      int firstCount = _firstList?.length ?? 0;
      int secondCount = _secondList?.length ?? 0;
      int thirdCount = _secondList?.length ?? 0;
      mostCount = max(firstCount, max(secondCount, thirdCount));
    }
    return mostCount;
  }
}
