import 'package:flutter/material.dart';
import '../widgets/number_keyboard.dart';
import '../models/calculator_model.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorModel _calculator = CalculatorModel();

  // 控制器用於管理輸入欄位
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _riskPercentageController = TextEditingController();
  final TextEditingController _riskRewardRatioController = TextEditingController();
  final TextEditingController _entryPriceController = TextEditingController();
  final TextEditingController _stopLossPriceController = TextEditingController();

  // 輸出值
  double? _positionValue;
  double? _exitPrice;

  // 當前選中的控制器
  TextEditingController? _currentController;

  // 添加一個變量來追踪當前正在編輯的控制器
  TextEditingController? _editingController;

  void _showNumberKeyboard(TextEditingController controller) {
    setState(() {
      _currentController = controller;
      _editingController = controller;
      _currentController!.clear();
    });

    // 根據控制器確定欄位名稱
    String fieldName = '';
    if (controller == _capitalController) {
      fieldName = '本金';
    } else if (controller == _riskPercentageController) {
      fieldName = '風險百分比';
    } else if (controller == _riskRewardRatioController) {
      fieldName = '盈虧比';
    } else if (controller == _entryPriceController) {
      fieldName = '進場價格';
    } else if (controller == _stopLossPriceController) {
      fieldName = '止損價格';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => GestureDetector(
          onTap: () {},
          child: NumberKeyboard(
            allowDecimal: true,
            currentValue: _currentController!.text,
            fieldName: fieldName,
            onNumberTap: (value) {
              String currentText = _currentController!.text;
              if (value == '.' && currentText.contains('.')) return;

              String newValue = currentText + value;

              // 處理首位為0的情況
              if (currentText == '0' && value != '.') {
                newValue = value;
              }

              setModalState(() {
                _currentController!.text = newValue;
              });

              setState(() {
                _calculate();
              });
            },
            onBackspace: () {
              String currentText = _currentController!.text;
              if (currentText.isNotEmpty) {
                setModalState(() {
                  _currentController!.text = currentText.substring(0, currentText.length - 1);
                });

                setState(() {
                  _calculate();
                });
              }
            },
            onDone: () {
              setState(() {
                _editingController = null;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    ).then((_) {
      setState(() {
        _editingController = null;
      });
    });
  }

  void _calculate() {
    try {
      setState(() {
        _calculator.capital = double.tryParse(_capitalController.text);
        _calculator.riskPercentage = double.tryParse(_riskPercentageController.text);
        _calculator.riskRewardRatio = double.tryParse(_riskRewardRatioController.text);
        _calculator.entryPrice = double.tryParse(_entryPriceController.text);
        _calculator.stopLossPrice = double.tryParse(_stopLossPriceController.text);

        _positionValue = _calculator.calculatePositionValue();
        _exitPrice = _calculator.calculateExitPrice();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('計算時發生錯誤，請檢查輸入值'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      _capitalController.clear();
      _riskPercentageController.clear();
      _riskRewardRatioController.clear();
      _entryPriceController.clear();
      _stopLossPriceController.clear();
      _positionValue = null;
      _exitPrice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('倉位價值計算', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: false,
        titleSpacing: 24.0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 本金輸入
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: GestureDetector(
                    onTap: () => _showNumberKeyboard(_capitalController),
                    child: Card(
                      elevation: 0,
                      color: Colors.white, // Added background color
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '\$',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  (_editingController == _capitalController && _capitalController.text.isEmpty)
                                      ? '0'
                                      : _capitalController.text.isEmpty
                                          ? '0'
                                          : _capitalController.text,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 8.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '輸入本金',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 風險百分比輸入
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // 風險百分比輸入
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showNumberKeyboard(_riskPercentageController),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.12,
                            child: Card(
                              color: Colors.grey[100],
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '風險百分比',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              (_editingController == _riskPercentageController && _riskPercentageController.text.isEmpty)
                                                  ? '0'
                                                  : _riskPercentageController.text.isEmpty
                                                      ? '0'
                                                      : _riskPercentageController.text,
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 8.0),
                                                child: Align(
                                                  alignment: Alignment.bottomLeft,
                                                  child: Text(
                                                    '%',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 盈虧比輸入
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showNumberKeyboard(_riskRewardRatioController),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.12,
                            child: Card(
                              color: Colors.grey[100],
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '盈虧比',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          (_editingController == _riskRewardRatioController && _riskRewardRatioController.text.isEmpty)
                                              ? '0'
                                              : _riskRewardRatioController.text.isEmpty
                                                  ? '0'
                                                  : _riskRewardRatioController.text,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 24.0, left: 8.0, bottom: 8.0),
                  child: Text(
                    '輸入交易參數',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // 進場價格輸入
                Row(
                  children: [
                    // 左側的Column（包含進場價格和止損價格）
                    Expanded(
                      child: Column(
                        children: [
                          // 進場價格輸入
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: GestureDetector(
                                onTap: () => _showNumberKeyboard(_entryPriceController),
                                child: Card(
                                  color: Color(0xFFFF1700),
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Icon(Icons.login, size: 24, color: Colors.white),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '進場價格',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  '\$',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    (_editingController == _entryPriceController && _entryPriceController.text.isEmpty)
                                                        ? '0'
                                                        : _entryPriceController.text.isEmpty
                                                            ? '0'
                                                            : _entryPriceController.text,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 止損價格輸入
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: GestureDetector(
                                onTap: () => _showNumberKeyboard(_stopLossPriceController),
                                child: Card(
                                  color: Colors.black,
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '止損價格',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  '\$',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    (_editingController == _stopLossPriceController && _stopLossPriceController.text.isEmpty)
                                                        ? '0'
                                                        : _stopLossPriceController.text.isEmpty
                                                            ? '0'
                                                            : _stopLossPriceController.text,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 右側的倉位價值結果Card
                    Expanded(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4 + 8,
                        child: Card(
                          color: Colors.black,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Icon(
                                      (_entryPriceController.text.isEmpty || _stopLossPriceController.text.isEmpty)
                                          ? Icons.trending_up
                                          : (double.parse(_entryPriceController.text) > double.parse(_stopLossPriceController.text))
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                      color: Colors.white,
                                      size: MediaQuery.of(context).size.width * 0.15,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '倉位價值',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(milliseconds: 1500),
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: _positionValue ?? 0,
                                          ),
                                          builder: (context, value, child) {
                                            return Text(
                                              _positionValue != null ? '\$${value.toStringAsFixed(2)}' : '---',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: _positionValue != null ? Colors.white : Color(0xFF6D2323),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '止盈價格',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(milliseconds: 1500),
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: _exitPrice ?? 0,
                                          ),
                                          builder: (context, value, child) {
                                            return Text(
                                              _exitPrice != null ? '\$${value.toStringAsFixed(2)}' : '---',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: _exitPrice != null ? Colors.white : Color(0xFF6D2323),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 重置按鈕
          Positioned(
            right: 16.0,
            bottom: 32.0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFF1700),
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
