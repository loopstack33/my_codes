import 'dart:async';
import 'dart:developer';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:psalmlog/views/profile/widgets/sub_tab_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'enums/dependencies.dart';

class InAppSubscription extends StatefulWidget {
  const InAppSubscription({super.key});

  @override
  State<InAppSubscription> createState() => _InAppSubscriptionState();
}

class _InAppSubscriptionState extends State<InAppSubscription> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async{
    if(!(await _iap.isAvailable())) return;

    //catch all purchase updates
    _subscription = InAppPurchase.instance.purchaseStream.listen((List<PurchaseDetails> purchaseDetailsList){
      handlePurchaseUpdates(purchaseDetailsList);
    },
    onDone: (){
      _subscription.cancel();
    },
    onError: (error){

    });
  }

  void handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async{
    for(int index = 0; index < purchaseDetailsList.length; index++){
      var purchaseStatus = purchaseDetailsList[index].status;

      switch (purchaseDetailsList[index].status){
        case PurchaseStatus.pending:
          log('purchase is pending');
          continue;
        case PurchaseStatus.error:
          log('purchase error');
          break;
        case PurchaseStatus.canceled:
          log('purchase cancelled');
          break;
        case PurchaseStatus.purchased:
          log('purchased');
          break;
        case PurchaseStatus.restored:
          log('purchase is restored');
          break;
      }

      if(purchaseDetailsList[index].pendingCompletePurchase){
        await _iap.completePurchase(purchaseDetailsList[index]).then((value){
          if(purchaseStatus == PurchaseStatus.purchased){
            // On purchase success call back
          }
        });
      }
    }
  }

  restorePurchases() async{
    try{
      await _iap.restorePurchases();
    }
    catch(error){
      //handle error if restore purchase failed
      log(error.toString());
    }
  }

  Future<void> buyNonConsumableProduct(String productID) async{
    try{
      Set<String> productIds = {productID};
      final ProductDetailsResponse productDetails = await _iap.queryProductDetails(productIds);
      productDetails;
      if(productDetails==null){
        return;
      }
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails.productDetails.first);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
    catch (e){
      log('Failed to buy plan $e');
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('In App Subscription'),
      ),
      body:  Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: () async{
            await buyNonConsumableProduct('test_plan');
            }, child: const Text('Buy Free Plan')),
          ],
        ),
      ),
    );
  }
}
