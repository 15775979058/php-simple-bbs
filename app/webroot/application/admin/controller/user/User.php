<?php
/**
 * Email:zhaojunlike@gmail.com
 * Date: 7/10/2017
 * Time: 7:11 PM
 */

namespace app\admin\controller\user;


use app\admin\controller\Auth;
use app\common\tools\Utils;

class User extends Auth
{

    /**
     * 修改提交
     */
    public function addEditUser()
    {
        if (input('method') == 'edit') {
            $data = \app\common\model\User::get(['id' => input('id', 0, 'intval')]);
            $newData = [
                'username' => input('username'),
                'nickname' => input('nickname'),
                'password' => input('password'),
                'mark' => input('mark'),
            ];
            //
            if ($data['password'] !== input('password')) {
                $newData['password'] = Utils::encodeUserPassword($newData['password'], $newData['username']);
            }
            //更新用户组
            $groups_ids = @$_POST['groups_id'];
            if (!$groups_ids || !is_array($groups_ids)) {
                $groups_ids = [];
            }
            model('auth_user_group')->where(['uid' => $data['id']])->delete();
            $data->userGroup()->saveAll($groups_ids);
            $ret = $data->allowField(true)->save($newData);
            if (false !== $ret) {
                $this->result([], 200, '更新成功!', "JSON");
            } else {
                $this->result([], 500, "更新失败!" . model('user')->getError(), "JSON");
            }
        } else {
            $data = [
                'username' => input('username'),
                'nickname' => input('nickname'),
                'password' => input('password'),
                'mark' => input('mark'),
            ];
            //
            $data['password'] = Utils::encodeUserPassword($data['password'], $data['username']);
            $ret = model('user')->validate("user.add")->save($data);
            if (false !== $ret) {
                $this->result([], 200, '新增成功!', "JSON");
            } else {
                $this->result([], 500, "新增失败!" . model('user')->getError(), "JSON");
            }
        }

    }

    /**
     * 用户列表
     * Email:zhaojunlike@gmail.com
     */
    public function index()
    {
        return $this->fetch();
    }

    public function getUserList()
    {
        $map = [];
        if (-1 !== input('status', -1, 'intval')) {
            $map['status'] = input('status');
        }
        $userList = model('user')
            //->where('id>1')
            ->where($map)
            ->order('id DESC')
            ->with('authGroup')
            ->with('userProfile')
            ->paginate($this->page_limit);

        foreach ($userList as &$user) {
            $groups = [];
            foreach ($user->auth_group as $authGroup) {
                $groups[] = $authGroup->authGroup->id;
                $authGroup->authGroup;
            }
            $user['groups_id'] = $groups;
            //获取用户的头像
        }
        $data['data_list'] = $userList;
        $this->result($data, 200, 'success', "JSON");
    }

    public function delete($id)
    {
        $map = [];
        if (is_array($id)) {
        } else {
            $map['id'] = $id;
        }
        if ($id <= 1) {
            $this->error("Root不可删除");
        }
        $ret = model('user')->where($map)->delete();
        if ($ret) {
            $this->result([], 200, "删除成功", "JSON");
        } else {
            $this->result([], 500, "删除失败", "JSON");
        }
    }


    public function changeStatus($id)
    {
        $post = \app\common\model\User::get(['id' => $id]);
        $post['status'] = $post['status'] == 1 ? 0 : 1;
        $post->save();
        $this->success("调整状态成功");
    }
}