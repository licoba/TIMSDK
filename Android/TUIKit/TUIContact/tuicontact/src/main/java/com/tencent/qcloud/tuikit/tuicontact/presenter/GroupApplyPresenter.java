package com.tencent.qcloud.tuikit.tuicontact.presenter;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IGroupApplyLayout;
import com.tencent.qcloud.tuikit.tuicontact.model.GroupInfoProvider;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;
import java.util.List;

public class GroupApplyPresenter {
    private final IGroupApplyLayout layout;
    private final GroupInfoProvider provider;

    private GroupInfo groupInfo;

    public GroupApplyPresenter(IGroupApplyLayout layout) {
        this.layout = layout;
        provider = new GroupInfoProvider();
    }

    public void setGroupInfo(GroupInfo groupInfo) {
        this.groupInfo = groupInfo;
    }

    public void loadGroupApplies() {
        provider.loadGroupApplies(groupInfo, new IUIKitCallback<List<GroupApplyInfo>>() {
            @Override
            public void onSuccess(List<GroupApplyInfo> data) {
                layout.onGroupApplyInfoListChanged(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public void acceptApply(GroupApplyInfo item, IUIKitCallback<Void> callback) {
        provider.acceptApply(item, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                item.setStatus(GroupApplyInfo.APPLIED);
                layout.onDataSetChanged();
                IUIKitCallback.callbackOnSuccess(callback, null);

                TUICore.notifyEvent(TUIConstants.TUIContact.Event.GroupApplication.KEY_GROUP_APPLICATION,
                    TUIConstants.TUIContact.Event.GroupApplication.SUB_KEY_GROUP_APPLICATION_NUM_CHANGED, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ContactUtils.callbackOnError(callback, errCode, errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void refuseApply(final GroupApplyInfo item, IUIKitCallback<Void> callback) {
        provider.refuseApply(item, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                item.setStatus(GroupApplyInfo.REFUSED);
                layout.onDataSetChanged();
                IUIKitCallback.callbackOnSuccess(callback, null);

                TUICore.notifyEvent(TUIConstants.TUIContact.Event.GroupApplication.KEY_GROUP_APPLICATION,
                    TUIConstants.TUIContact.Event.GroupApplication.SUB_KEY_GROUP_APPLICATION_NUM_CHANGED, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);
                ContactUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }
}
